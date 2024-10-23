defmodule Web.Api.EMR.SpecialistsControllerTest do
  use Web.ConnCase, async: true

  alias Proto.EMR.GetRecordSpecialistsResponse

  describe "GET index" do
    setup [:authenticate_patient]

    test "succeeds", %{conn: conn, current_patient: current_patient} do
      record = EMR.Factory.insert(:automatic_record, patient_id: current_patient.id)
      specialist = Authentication.Factory.insert(:verified_specialist)
      basic_info = SpecialistProfile.Factory.insert(:basic_info, specialist_id: specialist.id)

      medical_category = SpecialistProfile.Factory.insert(:medical_category)
      _ = SpecialistProfile.update_medical_categories([medical_category.id], specialist.id)

      cmd = %EMR.PatientRecords.Timeline.Commands.CreateCallItem{
        patient_id: current_patient.id,
        record_id: record.id,
        specialist_id: specialist.id
      }

      {:ok, _call_item} = EMR.create_call_timeline_item(cmd)

      conn = get(conn, emr_specialists_path(conn, :index, record.id))

      %GetRecordSpecialistsResponse{specialists: [fetched]} =
        proto_response(conn, 200, GetRecordSpecialistsResponse)

      assert fetched.first_name == basic_info.first_name
    end

    test "returns specialist when there are no timeline items", %{
      conn: conn,
      current_patient: current_patient
    } do
      specialist = Authentication.Factory.insert(:verified_specialist)
      basic_info = SpecialistProfile.Factory.insert(:basic_info, specialist_id: specialist.id)

      medical_category = SpecialistProfile.Factory.insert(:medical_category)
      _ = SpecialistProfile.update_medical_categories([medical_category.id], specialist.id)

      {:ok, %{id: record_id}} =
        EMR.PatientRecords.PatientRecord.create_visit_record(current_patient.id, specialist.id)

      conn = get(conn, emr_specialists_path(conn, :index, record_id))

      %GetRecordSpecialistsResponse{specialists: [fetched]} =
        proto_response(conn, 200, GetRecordSpecialistsResponse)

      assert fetched.first_name == basic_info.first_name
    end
  end
end
