defmodule Triage.OngoingDispatch do
  use Postgres.Schema
  use Postgres.Service

  @primary_key {:request_id, :string, autogenerate: false}

  schema "ongoing_dispatches" do
    embeds_one :patient_location_address, Triage.PatientLocationAddress
    field :region, :string

    field :nurse_id, :integer
    field :patient_id, :integer
    field :record_id, :integer
    field :requester_id, :integer

    field :requested_at, :utc_datetime_usec
    field :taken_at, :utc_datetime_usec

    timestamps()
  end

  @fields [
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
    |> unique_constraint(:_request_id,
      name: :ongoing_dispatches_pkey,
      message: "selected dispatch is no longer available"
    )
    |> unique_constraint(:_nurse_id,
      name: :ongoing_dispatches_nurse_id_index,
      message: "already accepted another dispatch"
    )
  end

  @spec fetch_by_nurse_id(pos_integer) :: {:ok, %__MODULE__{}} | {:error, :not_found}
  def fetch_by_nurse_id(nurse_id) do
    Repo.fetch_by(__MODULE__, nurse_id: nurse_id)
  end

  @spec fetch_by_request_id(String.t()) :: {:ok, %__MODULE__{}} | {:error, :not_found}
  def fetch_by_request_id(request_id) do
    Repo.fetch_by(__MODULE__, request_id: request_id)
  end
end
