defmodule EMR.PatientRecords.Timeline.ItemTest do
  use Postgres.DataCase, async: true

  alias EMR.PatientRecords.Timeline.Item
  alias EMR.PatientRecords.Timeline.ItemData

  describe "create_call_item/1" do
    test "creates timeline item and returns with preloaded call data" do
      patient = PatientProfile.Factory.insert(:patient)
      specialist = Authentication.Factory.insert(:specialist)
      record = EMR.Factory.insert(:automatic_record, patient_id: patient.id)

      cmd = %EMR.PatientRecords.Timeline.Commands.CreateCallItem{
        patient_id: patient.id,
        record_id: record.id,
        specialist_id: specialist.id
      }

      assert {:ok, call_item} = Item.create_call_item(cmd)
      assert %ItemData.Call{} = call_item.call
    end
  end

  describe "create_call_recording_item/1" do
    test "creates timeline item and returns with preloaded call data" do
      patient = PatientProfile.Factory.insert(:patient)
      record = EMR.Factory.insert(:automatic_record, patient_id: patient.id)

      cmd = %EMR.PatientRecords.Timeline.Commands.CreateCallRecordingItem{
        patient_id: patient.id,
        record_id: record.id,
        session_id: "SESSION",
        thumbnail_gcs_path: "THUMBNAIL",
        video_s3_path: "VIDEO",
        created_at: 1_596_458_061,
        duration: 60
      }

      assert {:ok, call_recording_item} = Item.create_call_recording_item(cmd)
      assert %ItemData.CallRecording{} = call_recording_item.call_recording
    end
  end

  describe "create_doctor_invitation_item/1" do
    test "creates timeline item and returns with preloaded invitation data" do
      patient = PatientProfile.Factory.insert(:patient)
      specialist = Authentication.Factory.insert(:specialist, type: "NURSE")
      record = EMR.Factory.insert(:automatic_record, patient_id: patient.id)
      medical_category = SpecialistProfile.Factory.insert(:medical_category)

      cmd = %EMR.PatientRecords.Timeline.Commands.CreateDoctorInvitationItem{
        medical_category_id: medical_category.id,
        patient_id: patient.id,
        record_id: record.id,
        specialist_id: specialist.id
      }

      assert {:ok, doctor_invitation_item} = Item.create_doctor_invitation_item(cmd)
      assert %ItemData.DoctorInvitation{} = doctor_invitation_item.doctor_invitation
    end
  end

  describe "create_ordered_tests_bundle_item/3" do
    test "created timeline item and returns with preloaded ordered tests" do
      patient = PatientProfile.Factory.insert(:patient)
      record = EMR.Factory.insert(:automatic_record, patient_id: patient.id)
      specialist = Authentication.Factory.insert(:specialist, type: "EXTERNAL")

      EMR.Factory.insert(:tests_category, %{id: 1, name: "category 1"})
      EMR.Factory.insert(:test, %{id: 1, category_id: 1, name: "test 1"})

      ordered_tests_bundle =
        EMR.Factory.insert(:ordered_tests_bundle,
          patient_id: patient.id,
          timeline_id: record.id,
          specialist_id: specialist.id
        )

      _test =
        EMR.Factory.insert(:ordered_test,
          description: "test name",
          medical_test_id: 1,
          bundle_id: ordered_tests_bundle.id
        )

      assert {:ok, %Item{ordered_tests_bundle: ordered_tests_bundle}} =
               Item.create_ordered_tests_bundle_item(
                 patient.id,
                 record.id,
                 ordered_tests_bundle.id
               )

      assert %EMR.PatientRecords.OrderedTestsBundle{
               ordered_tests: [
                 %EMR.PatientRecords.OrderedTest{
                   medical_test_id: 1,
                   description: "test name",
                   medical_test: medical_test
                 }
               ]
             } = ordered_tests_bundle

      assert %EMR.PatientRecords.MedicalLibrary.Test{
               name: "test 1"
             } = medical_test
    end
  end

  describe "create_vitals_v2_item/3" do
    test "created timeline item and returns with preloaded vitals data" do
      patient = PatientProfile.Factory.insert(:patient)
      record = EMR.Factory.insert(:automatic_record, patient_id: patient.id)
      nurse = Authentication.Factory.insert(:specialist, type: "NURSE")

      vitals =
        EMR.Factory.insert(:vitals,
          patient_id: patient.id,
          record_id: record.id,
          nurse_id: nurse.id
        )

      assert {:ok, vitals_v2_item} = Item.create_vitals_v2_item(patient.id, record.id, vitals.id)
      assert %EMR.PatientRecords.Vitals{} = vitals_v2_item.vitals_v2
    end
  end

  describe "create_dispatch_request_item/1" do
    test "creates timeline item and returns with preloaded dispatch request data" do
      patient = PatientProfile.Factory.insert(:patient)
      specialist = Authentication.Factory.insert(:specialist, type: "NURSE")
      record = EMR.Factory.insert(:automatic_record, patient_id: patient.id)

      cmd = %EMR.PatientRecords.Timeline.Commands.CreateDispatchRequestItem{
        patient_id: patient.id,
        patient_location_address: %{},
        record_id: record.id,
        request_id: UUID.uuid4(),
        requester_id: specialist.id
      }

      assert {:ok, dispatch_request_item} = Item.create_dispatch_request_item(cmd)
      assert %ItemData.DispatchRequest{} = dispatch_request_item.dispatch_request
    end
  end

  describe "create_hpi_item/3" do
    test "creates timeline item and returns with preloaded hpi data" do
      patient = PatientProfile.Factory.insert(:patient)
      record = EMR.Factory.insert(:automatic_record, patient_id: patient.id)
      hpi = EMR.Factory.insert(:hpi, patient_id: patient.id, timeline_id: record.id)

      assert {:ok, hpi_item} = Item.create_hpi_item(patient.id, record.id, hpi.id)
      assert %EMR.HPI{} = hpi_item.hpi
    end
  end

  test "all item data assocs should implement ItemData behaviour" do
    for item_type <- EMR.PatientRecords.Timeline.Item.item_types() do
      {:assoc, %{related: struct}} = EMR.PatientRecords.Timeline.Item.__changeset__()[item_type]

      assert EMR.PatientRecords.Timeline.ItemData in behaviours_list_for(struct),
             "#{inspect(struct)} does not implement ItemData behaviour"
    end
  end

  defp behaviours_list_for(struct) do
    struct.module_info[:attributes][:behaviour] || []
  end
end
