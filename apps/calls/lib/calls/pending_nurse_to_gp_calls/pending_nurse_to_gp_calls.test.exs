defmodule Calls.PendingNurseToGPCallsTest do
  use Postgres.DataCase, async: true

  describe "fetch/0" do
    test "returns all queue entries with the oldes at the top" do
      patient1 = PatientProfile.Factory.insert(:patient)
      nurse1 = Authentication.Factory.insert(:specialist, type: "NURSE")
      record1 = EMR.Factory.insert(:automatic_record, patient_id: patient1.id)

      patient2 = PatientProfile.Factory.insert(:patient)
      nurse2 = Authentication.Factory.insert(:specialist, type: "NURSE")
      record2 = EMR.Factory.insert(:automatic_record, patient_id: patient2.id)

      params = %{
        nurse_id: nurse1.id,
        patient_id: patient1.id,
        record_id: record1.id
      }

      {:ok, _pending_call} = Calls.PendingNurseToGPCalls.add_call(params)

      params = %{
        nurse_id: nurse2.id,
        patient_id: patient2.id,
        record_id: record2.id
      }

      {:ok, _pending_call} = Calls.PendingNurseToGPCalls.add_call(params)

      assert {:ok, [entry1, entry2]} = Calls.PendingNurseToGPCalls.fetch()
      assert entry1.nurse_id == nurse1.id
      assert entry2.nurse_id == nurse2.id
    end
  end
end
