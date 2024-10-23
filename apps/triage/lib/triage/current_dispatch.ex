defmodule Triage.CurrentDispatch do
  @moduledoc """
  Postgres view (union all on pending and ongoing dispatches)

  Defined in `Postgres.Repo.Migrations.AddPatientLocationAddressToDispatches`
  """

  use Postgres.Schema
  use Postgres.Service

  @primary_key {:request_id, :string, autogenerate: false}

  schema "current_dispatches" do
    embeds_one :patient_location_address, Triage.PatientLocationAddress
    field :region, :string
    field :status, :string

    field :nurse_id, :integer
    field :patient_id, :integer
    field :record_id, :integer
    field :requester_id, :integer

    field :requested_at, :utc_datetime_usec
    field :taken_at, :utc_datetime_usec

    timestamps()
  end

  @spec fetch_all() :: {:ok, [%__MODULE__{}]}
  def fetch_all do
    Repo.fetch_all(__MODULE__)
  end

  @spec fetch_by_request_id(String.t()) :: {:ok, %__MODULE__{}} | {:error, :not_found}
  def fetch_by_request_id(request_id) do
    Repo.fetch_by(__MODULE__, request_id: request_id)
  end
end
