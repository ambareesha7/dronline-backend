defmodule EMR.PatientRecords.CallTypePatientRecordTest do
  use Postgres.DataCase, async: true

  alias EMR.PatientRecords.CallTypePatientRecord
  alias EMR.PatientRecords.PatientRecord
  alias EMR.PatientRecords.VideoRecordings.TokboxSession

  describe "create/3" do
    test """
      - returns created CALL Record
      - creates Tokbox session
    """ do
      specialist_id = 1
      patient_id = 10
      call_session_id = "call_session_id"

      assert {:ok,
              %PatientRecord{
                id: record_id,
                type: :CALL
              }} =
               CallTypePatientRecord.create(
                 patient_id,
                 specialist_id,
                 call_session_id
               )

      assert %{
               record_id: session_record_id
             } = Repo.one(TokboxSession)

      assert session_record_id == record_id
    end
  end
end
