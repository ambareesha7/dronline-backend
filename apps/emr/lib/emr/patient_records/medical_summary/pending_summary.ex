defmodule EMR.PatientRecords.MedicalSummary.PendingSummary do
  use Postgres.Schema
  use Postgres.Service

  alias EMR.PatientRecords.Autoclose.Saga, as: AutocloseSaga

  schema "pending_medical_summaries" do
    field :patient_id, :integer
    field :record_id, :integer
    field :specialist_id, :integer

    timestamps()
  end

  @spec create(pos_integer, pos_integer, pos_integer) :: {:ok, :created}
  def create(patient_id, record_id, specialist_id) do
    {:ok, %__MODULE__{}} =
      %__MODULE__{patient_id: patient_id, record_id: record_id, specialist_id: specialist_id}
      |> Repo.insert(on_conflict: :nothing)

    :ok = AutocloseSaga.register_pending_medical_summary(patient_id, record_id, specialist_id)

    {:ok, :created}
  end

  @spec resolve(pos_integer, pos_integer) :: :ok
  def resolve(record_id, specialist_id) do
    _ =
      __MODULE__
      |> where(record_id: ^record_id, specialist_id: ^specialist_id)
      |> Repo.delete_all()

    :ok
  end

  @spec get_by_specialist_id(pos_integer) :: %__MODULE__{} | nil
  def get_by_specialist_id(specialist_id) do
    __MODULE__
    |> where(specialist_id: ^specialist_id)
    |> order_by(asc: :inserted_at)
    |> limit(1)
    |> Repo.one()
  end
end
