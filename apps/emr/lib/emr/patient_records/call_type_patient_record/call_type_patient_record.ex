defmodule EMR.PatientRecords.CallTypePatientRecord do
  alias EMR.PatientRecords.PatientRecord
  alias EMR.PatientRecords.VideoRecordings.TokboxSession
  alias Postgres.Repo

  def create(patient_id, specialist_id, call_session_id) do
    fn ->
      with {:ok, record} <- PatientRecord.create_call_record(patient_id, specialist_id),
           :ok <- TokboxSession.assign_tokbox_session_to_record(record.id, call_session_id) do
        record
      end
    end
    |> Repo.transaction()
    |> case do
      {:ok, result} -> {:ok, result}
      {:error, _failed_operation, changeset, _changes_so_far} -> {:error, changeset}
    end
  end
end
