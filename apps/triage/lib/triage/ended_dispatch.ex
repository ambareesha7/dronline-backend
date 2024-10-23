defmodule Triage.EndedDispatch do
  use Postgres.Schema
  use Postgres.Service

  @primary_key {:request_id, :string, autogenerate: false}

  schema "ended_dispatches" do
    embeds_one :patient_location_address, Triage.PatientLocationAddress
    field :region, :string

    field :nurse_id, :integer
    field :patient_id, :integer
    field :record_id, :integer
    field :requester_id, :integer

    field :ended_at, :utc_datetime_usec
    field :requested_at, :utc_datetime_usec
    field :taken_at, :utc_datetime_usec

    timestamps()
  end

  @fields [
    :ended_at,
    :nurse_id,
    :patient_id,
    :record_id,
    :region,
    :request_id,
    :requested_at,
    :requester_id,
    :taken_at
  ]

  def changeset(%__MODULE__{} = struct, params) do
    struct
    |> cast(params, @fields)
    |> cast_embed(:patient_location_address, required: true)
    |> validate_required(@fields)
    |> Triage.Regions.validate_region_support()
    |> foreign_key_constraint(:nurse_id)
    |> foreign_key_constraint(:patient_id)
    |> foreign_key_constraint(:record_id)
    |> foreign_key_constraint(:requester_id)
  end

  @spec fetch(map) :: {:ok, [%__MODULE__{}], String.t() | nil}
  def fetch(params) do
    params = parse_params(params)

    {:ok, result, next_record} =
      __MODULE__
      |> where(^next_records_condition(params))
      |> order_by_params(params)
      |> Repo.fetch_paginated(params)

    {:ok, result, generate_next_token(next_record, params)}
  end

  @spec get_total_count :: non_neg_integer()
  def get_total_count do
    __MODULE__
    |> select(count())
    |> Repo.one()
  end

  @spec fetch_by_request_id(String.t()) :: {:ok, %__MODULE__{}} | {:error, :not_found}
  def fetch_by_request_id(request_id) do
    Repo.fetch_by(__MODULE__, request_id: request_id)
  end

  defp parse_params(params) do
    %{
      "next_id" => nil,
      "next_value" => nil,
      "order" => "desc",
      "sort_by" => "ended_at"
    }
    |> Map.merge(params)
    |> Map.merge(Postgres.Option.decode_next_token(params["next_token"]))
    |> Map.update!("order", &parse_order/1)
    |> Map.update!("sort_by", &parse_sort_by/1)
  end

  defp order_by_params(query, %{"sort_by" => field_name, "order" => order}) do
    order_by(query, [ed], [{^order, field(ed, ^field_name)}, {^order, ed.request_id}])
  end

  defp next_records_condition(%{"next_value" => nil}), do: true

  defp next_records_condition(%{"order" => :asc} = params) do
    %{"next_id" => id, "next_value" => field_value, "sort_by" => field_name} = params

    dynamic(
      [ed],
      (field(ed, ^field_name) == ^field_value and ed.request_id >= ^id) or
        field(ed, ^field_name) > ^field_value
    )
  end

  defp next_records_condition(%{"order" => :desc} = params) do
    %{"next_id" => id, "next_value" => field_value, "sort_by" => field_name} = params

    dynamic(
      [ed],
      (field(ed, ^field_name) == ^field_value and ed.request_id <= ^id) or
        field(ed, ^field_name) < ^field_value
    )
  end

  defp generate_next_token(nil, _params), do: nil

  defp generate_next_token(next_record, params) do
    %{
      "next_id" => next_record.request_id,
      "next_value" => Map.get(next_record, params["sort_by"]),
      "order" => params["order"],
      "sort_by" => params["sort_by"]
    }
    |> Postgres.Option.encode_next_token()
  end

  defp parse_order(order) when is_binary(order) do
    order |> String.to_existing_atom() |> parse_order()
  end

  defp parse_order(order) when order in [:asc, :desc] do
    order
  end

  defp parse_sort_by(sort_by) when is_binary(sort_by) do
    sort_by |> String.to_existing_atom() |> parse_sort_by()
  end

  defp parse_sort_by(sort_by) when sort_by in [:ended_at, :requested_at, :taken_at] do
    sort_by
  end
end
