defmodule EMR.PatientRecords.InvolvedSpecialists do
  use Postgres.Schema
  use Postgres.Service

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "records_involved_specialists" do
    field :patient_id, :integer
    field :record_id, :integer
    field :involved_specialist_id, :integer

    timestamps()
  end

  @spec register_involvement(pos_integer, pos_integer, pos_integer) :: :ok
  def register_involvement(patient_id, record_id, involved_specialist_id) do
    {:ok, %__MODULE__{}} =
      %__MODULE__{
        patient_id: patient_id,
        record_id: record_id,
        involved_specialist_id: involved_specialist_id
      }
      |> Repo.insert(on_conflict: :nothing)

    :ok
  end

  @spec get_for_record(pos_integer, pos_integer) :: [involved_specialist_ids :: pos_integer]
  def get_for_record(patient_id, record_id) do
    __MODULE__
    |> where(patient_id: ^patient_id)
    |> where(record_id: ^record_id)
    |> select([is], is.involved_specialist_id)
    |> Repo.all()
  end
end
