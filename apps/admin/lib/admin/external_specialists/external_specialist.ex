defmodule Admin.ExternalSpecialists.ExternalSpecialist do
  use Postgres.Schema
  use Postgres.Service

  alias __MODULE__

  defmodule SpecialistBasicInfo do
    use Postgres.Schema

    schema "specialist_basic_infos" do
      field :first_name, :string
      field :last_name, :string
      field :image_url, :string
    end
  end

  defmodule MedicalCategory do
    use Postgres.Schema

    schema "medical_categories" do
      field :name, :string
      field :parent_category_id, :integer
    end
  end

  schema "specialists" do
    field :approval_status, :string
    field :approval_status_updated_at, :naive_datetime_usec
    field :type, :string
    field :email, :string
    field :onboarding_completed_at, :naive_datetime_usec

    timestamps()

    has_one :basic_info, SpecialistBasicInfo, foreign_key: :specialist_id

    many_to_many :medical_categories, MedicalCategory,
      join_through: "specialists_medical_categories",
      join_keys: [specialist_id: :id, medical_category_id: :id]
  end

  @spec fetch(map) :: {:ok, [%ExternalSpecialist{}], String.t() | nil}
  @doc """
  Fetches external doctor with ones waiting for approval at the top.
  Sorts waiting doctors by join timestamp and rest of freelancers by approval_status_updated_at,
  both in DESC order.
  Does not fetches specialist who did not finished onboarding.
  """
  def fetch(params) do
    params = parse_params(params)

    {:ok, result, next_record} =
      __MODULE__
      |> join(:inner, [s], bi in assoc(s, :basic_info))
      |> join(:inner, [s], mc in assoc(s, :medical_categories))
      |> Postgres.TSQuery.filter(params["filter"],
        join: "specialist_filter_datas",
        on: :specialist_id
      )
      |> where([s], s.type == "EXTERNAL")
      |> where([s], not is_nil(s.onboarding_completed_at))
      |> where(^next_record(params))
      |> filter_by_medical_categories(params)
      |> order_by_params(params)
      |> preload([s, bi, mc], basic_info: bi, medical_categories: mc)
      |> Repo.fetch_paginated(params)

    {:ok, result, generate_next_token(next_record, params)}
  end

  defp parse_params(params) do
    %{
      "next_id" => nil,
      "next_value" => nil,
      "order" => "asc",
      "sort_by" => :default,
      "categories_ids" => nil
    }
    |> Map.merge(params)
    |> Map.merge(Postgres.Option.decode_next_token(params["next_token"]))
    |> Map.update!("sort_by", &parse_sort_by/1)
    |> Map.update!("categories_ids", &parse_categories_ids/1)
  end

  defp parse_sort_by(sort_by) when is_atom(sort_by), do: sort_by
  defp parse_sort_by("joined_at"), do: :inserted_at
  defp parse_sort_by("status"), do: :approval_status
  defp parse_sort_by(sort_by), do: String.to_existing_atom(sort_by)

  defp parse_categories_ids(nil), do: nil

  defp parse_categories_ids(categories_ids) do
    categories_ids |> String.split(",") |> Enum.map(&String.to_integer/1)
  end

  defp filter_by_medical_categories(query, %{"categories_ids" => nil}), do: query

  defp filter_by_medical_categories(query, %{"categories_ids" => categories_ids}) do
    where(query, [_s, _bi, mc], mc.id in ^categories_ids)
  end

  defp next_record(%{"next_id" => nil, "next_value" => nil}), do: true

  # CASES FOR DEFAULT ORDER

  defp next_record(
         %{"next_value" => %{"approval_status" => "WAITING"}, "sort_by" => :default} = params
       ) do
    %{"next_id" => id, "next_value" => %{"joined_at" => joined_at}} = params

    dynamic(
      [s],
      (s.approval_status == "WAITING" and
         ((s.inserted_at == ^joined_at and s.id <= ^id) or s.inserted_at < ^joined_at)) or
        s.approval_status != "WAITING"
    )
  end

  defp next_record(%{"sort_by" => :default} = params) do
    %{
      "next_value" => %{"approval_status_updated_at" => approval_status_updated_at},
      "next_id" => id
    } = params

    dynamic(
      [s],
      s.approval_status != "WAITING" and
        (s.approval_status_updated_at < ^approval_status_updated_at or
           (s.approval_status_updated_at == ^approval_status_updated_at and s.id <= ^id))
    )
  end

  # CASES FOR SORTING

  defp next_record(%{"sort_by" => field_name, "order" => "asc"} = params)
       when field_name in [:first_name, :last_name] do
    %{"next_id" => id, "next_value" => field_value} = params

    dynamic(
      [s, bi],
      (field(bi, ^field_name) == ^field_value and s.id >= ^id) or
        field(bi, ^field_name) > ^field_value or is_nil(field(bi, ^field_name))
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

  defp next_record(%{"sort_by" => field_name, "order" => "asc"} = params)
       when field_name in [:email, :inserted_at, :approval_status] do
    %{"next_id" => id, "next_value" => field_value} = params

    dynamic(
      [s],
      (field(s, ^field_name) == ^field_value and s.id >= ^id) or
        field(s, ^field_name) > ^field_value or is_nil(field(s, ^field_name))
    )
  end

  defp next_record(%{"sort_by" => field_name, "order" => "desc"} = params)
       when field_name in [:email, :inserted_at, :approval_status] do
    %{"next_id" => id, "next_value" => field_value} = params

    dynamic(
      [s],
      (field(s, ^field_name) == ^field_value and s.id <= ^id) or
        field(s, ^field_name) < ^field_value or is_nil(field(s, ^field_name))
    )
  end

  # APPLY ORDER ON RIGHT FIELDS

  defp order_by_params(query, %{"sort_by" => :default}) do
    order_by(query, [s], [
      fragment("? = 'WAITING' DESC", s.approval_status),
      desc: :approval_status_updated_at,
      desc: :inserted_at,
      desc: :id
    ])
  end

  defp order_by_params(query, %{"sort_by" => field_name, "order" => order})
       when field_name in [:first_name, :last_name] do
    order = parse_order(order, field_name)
    order_by(query, [s, bi], [{^order, field(bi, ^field_name)}, {^order, s.id}])
  end

  defp order_by_params(query, %{"sort_by" => field_name, "order" => order})
       when field_name in [:email, :inserted_at, :approval_status] do
    order = parse_order(order, field_name)
    order_by(query, [s], [{^order, field(s, ^field_name)}, {^order, s.id}])
  end

  defp parse_order("asc", _sort_by), do: :asc_nulls_last
  defp parse_order("desc", _sort_by), do: :desc_nulls_last

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

  defp get_value(next_record, :default) do
    %{
      "approval_status" => next_record.approval_status,
      "approval_status_updated_at" => next_record.approval_status_updated_at,
      "joined_at" => next_record.inserted_at
    }
  end

  defp get_value(next_record, sort_by)
       when sort_by in [:email, :inserted_at, :approval_status] do
    Map.get(next_record, sort_by)
  end

  defp get_value(next_record, sort_by) when sort_by in [:first_name, :last_name] do
    Map.get(next_record.basic_info, sort_by)
  end

  @spec fetch_by_id(pos_integer) :: {:ok, %__MODULE__{}} | {:error, :not_found}
  def fetch_by_id(specialist_id) do
    Repo.fetch(__MODULE__, specialist_id)
  end

  @fields [:approval_status, :approval_status_updated_at]
  defp set_approval_status_changeset(specialist, params) do
    specialist
    |> cast(params, @fields)
    |> validate_required(@fields)
    |> validate_inclusion(:approval_status, ["VERIFIED", "REJECTED"])
  end

  @spec set_approval_status(%__MODULE__{}, String.t()) ::
          {:ok, %__MODULE__{}}
          | {:error, Ecto.Changeset.t()}
          | {:error, :not_found}
  def set_approval_status(%__MODULE__{} = specialist, status) do
    params = %{
      approval_status: status,
      approval_status_updated_at: DateTime.utc_now()
    }

    specialist
    |> set_approval_status_changeset(params)
    |> Repo.update()
  end
end
