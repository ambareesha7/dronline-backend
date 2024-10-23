defmodule EMR.PatientRecords.Timeline.ItemData.CallTest do
  use Postgres.DataCase, async: true

  alias EMR.PatientRecords.Timeline.ItemData.Call

  describe "create/4" do
    test "creates call item when medical_category_id isn't present" do
      patient = PatientProfile.Factory.insert(:patient)
      specialist = Authentication.Factory.insert(:specialist)
      record = EMR.Factory.insert(:automatic_record, patient_id: patient.id)

      cmd = %EMR.PatientRecords.Timeline.Commands.CreateCallItem{
        patient_id: patient.id,
        record_id: record.id,
        specialist_id: specialist.id
      }

      assert {:ok, %Call{}} = Call.create(cmd)
    end

    test "creates call item when medical_category_id is present" do
      patient = PatientProfile.Factory.insert(:patient)
      specialist = Authentication.Factory.insert(:specialist)
      record = EMR.Factory.insert(:automatic_record, patient_id: patient.id)
      medical_category = VisitsScheduling.Factory.insert(:medical_category)

      cmd = %EMR.PatientRecords.Timeline.Commands.CreateCallItem{
        medical_category_id: medical_category.id,
        patient_id: patient.id,
        record_id: record.id,
        specialist_id: specialist.id
      }

      assert {:ok, %Call{}} = Call.create(cmd)
    end
  end
end
