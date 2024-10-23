defmodule Admin.InternalSpecialists.InternalSpecialist do
  use Postgres.Schema
  use Postgres.Service

  import Mockery.Macro

  alias __MODULE__

  defmodule SpecialistBasicInfo do
    use Postgres.Schema

    schema "specialist_basic_infos" do
      field :title, :string
      field :first_name, :string
      field :last_name, :string
      field :image_url, :string
    end
  end

  schema "specialists" do
    field :email, :string
    field :type, :string
    field :verified, :boolean, default: true

    field :auth_token, :string
    field :password, :string, virtual: true
    field :password_hash, :string
    field :password_recovery_token, :string
    field :password_recovery_token_expire_at, :naive_datetime_usec

    field :onboarding_completed_at, :naive_datetime_usec

    has_one :basic_info, SpecialistBasicInfo, foreign_key: :specialist_id

    timestamps()
  end

  @fields [:email, :type]
  @required [:email, :password_hash, :type]
  defp create_changeset(struct, params) do
    struct
    |> cast(params, @fields)
    |> generate_token(:auth_token, 30)
    |> put_change(:password, :crypto.strong_rand_bytes(30))
    |> handle_password()
    |> validate_required(@required)
    |> validate_inclusion(:type, ["NURSE", "GP", "EXTERNAL"])
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:auth_token)
    |> unique_constraint(:email)
  end

  defp password_recovery_changeset(specialist) do
    specialist
    |> change()
    |> generate_token(:password_recovery_token, 20)
    |> unique_constraint(:password_recovery_token)
  end

  @spec create(map) :: {:ok, map} | {:error, Ecto.Changeset.t()}
  def create(params) do
    %__MODULE__{}
    |> create_changeset(params)
    |> Repo.insert()
  end

  @spec fetch_by_id(pos_integer) :: {:ok, map} | {:error, :not_found}
  def fetch_by_id(id) do
    __MODULE__
    |> where([s], s.type in ["GP", "NURSE"])
    |> where([s], s.id == ^id)
    |> Repo.fetch_one()
    |> case do
      {:ok, specialist} -> {:ok, parse_specialist_info(specialist)}
      error -> error
    end
  end

  defp parse_specialist_info(specialist) do
    %{
      completed_at: parse_timestamp(specialist.onboarding_completed_at),
      created_at: parse_timestamp(specialist.inserted_at),
      type: specialist.type |> String.to_existing_atom()
    }
  end

  defp parse_timestamp(nil), do: nil
  defp parse_timestamp(timestamp), do: %{timestamp: Timex.to_unix(timestamp)}

  @doc """
  Returns internal specialists list and next token which can be used in next request to fetch following records.
  If `sort_by` parameter is provided, returned list is sorted in order given by 'order' param.

  Params:
  * `filter` - value used to filter results
  * `sort_by` - name of field which defines order of list
  * `order` - direction of ordering, allowed values:
     "email", "first_name", "last_name", "status", "type"
  * `next_token` - contains encoded informations allowing
    pagination. Decoded contains of `next_id`, `next_value`,
    `sort_by`, `order`.

  Note: Function supports pagination
  """
  @spec fetch_all(map) :: {:ok, [], next_token :: String.t()}
  def fetch_all(params) do
    params = parse_params(params)

    {:ok, result, next_record} =
      __MODULE__
      |> join(:left, [s], bi in assoc(s, :basic_info))
      |> Postgres.TSQuery.filter(params["filter"],
        join: "specialist_filter_datas",
        on: :specialist_id
      )
      |> where([s], s.type in ["GP", "NURSE"])
      |> where(^next_record(params))
      |> filter_by_specialist_type(params)
      |> order_by_params(params)
      |> preload([_s, bi], basic_info: bi)
      |> Repo.fetch_paginated(params)

    {:ok, Enum.map(result, &parse_result/1), generate_next_token(next_record, params)}
  end

  # PARSING PARAMS

  defp parse_params(params) do
    %{
      "next_id" => nil,
      "next_value" => nil,
      "type" => nil
    }
    |> Map.merge(params)
    |> Map.merge(Postgres.Option.decode_next_token(params["next_token"]))
    |> Map.update("sort_by", :id, &parse_sort_by/1)
    |> Map.put_new("order", "asc")
  end

  defp parse_sort_by(sort_by) when is_atom(sort_by), do: sort_by
  defp parse_sort_by("status"), do: :onboarding_completed_at
  defp parse_sort_by(sort_by), do: String.to_existing_atom(sort_by)

  # GENERATING NEXT_TOKEN

  defp generate_next_token(nil, _params), do: nil

  defp generate_next_token(next_record, params) do
    %{
      "next_id" => next_record.id,
      "next_value" => get_value(next_record, params["sort_by"]),
      "order" => params["order"],
      "sort_by" => params["sort_by"]
    }
    |> Postgres.Option.encode_next_token()
  end

  defp get_value(next_record, sort_by)
       when sort_by in [:id, :email, :onboarding_completed_at, :type] do
    Map.get(next_record, sort_by)
  end

  defp get_value(%{basic_info: nil}, sort_by) when sort_by in [:first_name, :last_name], do: nil

  defp get_value(next_record, sort_by) when sort_by in [:first_name, :last_name] do
    Map.get(next_record.basic_info, sort_by)
  end

  defp get_value(_, _), do: nil

  defp filter_by_specialist_type(query, %{"type" => nil}), do: query
  defp filter_by_specialist_type(query, %{"type" => type}), do: where(query, type: ^type)

  # CREATING WHERE CONDITION WHICH FETCHES ONLY FOLLOWING RECORDS

  defp next_record(%{"next_id" => nil, "next_value" => nil}), do: true
  defp next_record(%{"sort_by" => :id, "next_id" => id}), do: dynamic([s], s.id >= ^id)

  defp next_record(%{
         "sort_by" => field_name,
         "next_id" => id,
         "next_value" => nil,
         "order" => "asc"
       })
       when field_name in [:first_name, :last_name] do
    dynamic(
      [s, bi],
      is_nil(field(bi, ^field_name)) and s.id >= ^id
    )
  end

  defp next_record(%{"sort_by" => field_name, "order" => "asc"} = params)
       when field_name in [:first_name, :last_name] do
    %{"next_id" => id, "next_value" => field_value} = params

    dynamic(
      [s, bi],
      (field(bi, ^field_name) == ^field_value and s.id >= ^id) or
        field(bi, ^field_name) > ^field_value or is_nil(field(bi, ^field_name))
    )
  end

  defp next_record(%{
         "sort_by" => field_name,
         "next_id" => id,
         "next_value" => nil,
         "order" => "desc"
       })
       when field_name in [:first_name, :last_name] do
    dynamic(
      [s, bi],
      is_nil(field(bi, ^field_name)) and s.id <= ^id
    )
  end

  defp next_record(%{"sort_by" => field_name, "order" => "desc"} = params)
       when field_name in [:first_name, :last_name] do
    %{"next_id" => id, "next_value" => field_value} = params

    dynamic(
      [s, bi],
      (field(bi, ^field_name) == ^field_value and s.id <= ^id) or
        field(bi, ^field_name) < ^field_value or is_nil(field(bi, ^field_name))
    )
  end

  defp next_record(%{
         "sort_by" => field_name,
         "next_id" => id,
         "next_value" => nil,
         "order" => "asc"
       })
       when field_name in [:email, :type] do
    dynamic(
      [s],
      is_nil(field(s, ^field_name)) and s.id >= ^id
    )
  end

  defp next_record(%{
         "sort_by" => :onboarding_completed_at,
         "next_id" => id,
         "next_value" => nil,
         "order" => "asc"
       }) do
    dynamic(
      [s],
      (is_nil(s.onboarding_completed_at) and s.id >= ^id) or not is_nil(s.onboarding_completed_at)
    )
  end

  defp next_record(%{
         "sort_by" => :onboarding_completed_at,
         "next_id" => id,
         "next_value" => field_value,
         "order" => "asc"
       }) do
    dynamic(
      [s],
      not is_nil(s.onboarding_completed_at) and
        ((s.onboarding_completed_at == ^field_value and s.id >= ^id) or
           s.onboarding_completed_at > ^field_value)
    )
  end

  defp next_record(%{"sort_by" => field_name, "order" => "asc"} = params)
       when field_name in [:email, :type] do
    %{"next_id" => id, "next_value" => field_value} = params

    dynamic(
      [s],
      (field(s, ^field_name) == ^field_value and s.id >= ^id) or
        field(s, ^field_name) > ^field_value or is_nil(field(s, ^field_name))
    )
  end

  defp next_record(%{
         "sort_by" => field_name,
         "next_id" => id,
         "next_value" => nil,
         "order" => "desc"
       })
       when field_name in [:email, :onboarding_completed_at, :type] do
    dynamic(
      [s],
      is_nil(field(s, ^field_name)) and s.id <= ^id
    )
  end

  defp next_record(%{"sort_by" => field_name, "order" => "desc"} = params)
       when field_name in [:email, :onboarding_completed_at, :type] do
    %{"next_id" => id, "next_value" => field_value} = params

    dynamic(
      [s],
      (field(s, ^field_name) == ^field_value and s.id <= ^id) or
        field(s, ^field_name) < ^field_value or is_nil(field(s, ^field_name))
    )
  end

  # APPLY ORDER ON RIGHT FIELDS

  defp order_by_params(query, %{"sort_by" => :id}), do: order_by(query, [s], asc: s.id)

  defp order_by_params(query, %{"sort_by" => field_name, "order" => order})
       when field_name in [:first_name, :last_name] do
    order = parse_order(order, field_name)
    order_by(query, [s, bi], [{^order, field(bi, ^field_name)}, {^order, s.id}])
  end

  defp order_by_params(query, %{"sort_by" => field_name, "order" => order})
       when field_name in [:email, :onboarding_completed_at, :type] do
    order = parse_order(order, field_name)
    order_by(query, [s], [{^order, field(s, ^field_name)}, {^order, s.id}])
  end

  defp parse_order("asc", :onboarding_completed_at), do: :asc_nulls_first
  defp parse_order("asc", _sort_by), do: :asc_nulls_last
  defp parse_order("desc", _sort_by), do: :desc_nulls_last

  @doc """
  Creates password recovery token

  In case of uniqueness error on recovery token it will loop.
  By design it should not be possible to get `{:error, changeset}` as result.
  """
  @spec create_password_recovery_token(%__MODULE__{}) :: {:ok, %__MODULE__{}}
  def create_password_recovery_token(specialist) do
    changeset = password_recovery_changeset(specialist)

    case Repo.update(changeset) do
      {:ok, %__MODULE__{} = specialist} ->
        {:ok, specialist}

      {:error, changeset} ->
        handle_password_recovery_error(changeset, specialist)
    end
  end

  defp parse_result(%InternalSpecialist{} = specialist) do
    %{
      id: specialist.id,
      first_name: parse_basic_info_field(specialist.basic_info, :first_name),
      last_name: parse_basic_info_field(specialist.basic_info, :last_name),
      email: specialist.email,
      title: specialist.basic_info |> parse_basic_info_field(:title) |> parse_title_result(),
      type: specialist.type |> String.to_existing_atom(),
      status: parse_status(specialist.onboarding_completed_at),
      created_at: parse_timestamp(specialist.inserted_at),
      completed_at: parse_timestamp(specialist.onboarding_completed_at)
    }
  end

  defp handle_password_recovery_error(changeset, specialist) do
    if Enum.any?(
         changeset.errors,
         &match?({:password_recovery_token, {"has already been taken", _}}, &1)
       ) do
      create_password_recovery_token(specialist)
    else
      Sentry.Context.set_extra_context(%{changeset: changeset})

      raise "failure in #{inspect(__MODULE__)}.create_password_recovery_token/1"
    end
  end

  defp parse_basic_info_field(nil, _field), do: nil
  defp parse_basic_info_field(basic_info, field), do: Map.get(basic_info, field)

  defp parse_status(nil), do: :CREATED
  defp parse_status(_), do: :COMPLETED

  defp parse_title_result(nil), do: nil
  defp parse_title_result(title), do: title |> String.to_existing_atom()

  defp handle_password(changeset) do
    password = get_change(changeset, :password)

    changeset
    |> validate_required([:password])
    |> case do
      %{valid?: true} = changeset ->
        changeset |> put_change(:password_hash, Pbkdf2.hash_pwd_salt(password))

      changeset ->
        changeset
    end
  end

  defp generate_token(changeset, field, size) do
    changeset |> put_change(field, mockable(Admin.Random).url_safe(size))
  end
end
