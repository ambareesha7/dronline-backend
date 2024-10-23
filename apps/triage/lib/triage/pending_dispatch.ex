defmodule Triage.PendingDispatch do
  use Postgres.Schema
  use Postgres.Service

  @primary_key {:request_id, :string, autogenerate: false}

  schema "pending_dispatches" do
    embeds_one :patient_location_address, Triage.PatientLocationAddress
    field :region, :string

    field :patient_id, :integer
    field :record_id, :integer
    field :requester_id, :integer

    field :requested_at, :utc_datetime_usec

    timestamps()
  end

  @fields [
    :patient_id,
    :record_id,
    :region,
    :request_id,
    :requested_at,
    :requester_id
  ]

  def changeset(%__MODULE__{} = struct, params) do
    struct
    |> cast(params, @fields)
    |> cast_embed(:patient_location_address, required: true)
    |> validate_required(@fields)
    |> Triage.Regions.validate_region_support()
    |> foreign_key_constraint(:patient_id)
    |> foreign_key_constraint(:record_id)
    |> foreign_key_constraint(:requester_id)
  end

  @spec fetch_all :: {:ok, [%__MODULE__{}]}
  def fetch_all do
    __MODULE__
    |> order_by(asc: :requested_at)
    |> Repo.fetch_all()
  end

  @spec fetch_by_request_id(String.t()) :: {:ok, %__MODULE__{}} | {:error, :not_found}
  def fetch_by_request_id(request_id) do
    Repo.fetch(__MODULE__, request_id)
  end
end
