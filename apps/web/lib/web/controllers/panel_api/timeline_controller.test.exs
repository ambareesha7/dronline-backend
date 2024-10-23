defmodule Web.PanelApi.TimelineControllerTest do
  use Web.ConnCase, async: true

  alias Proto.Timeline.GetTimelineResponse

  describe "GET timeline" do
    setup [:authenticate_gp]

    test "returns timeline and associated specialists profiles", %{conn: conn} do
      patient = PatientProfile.Factory.insert(:patient)
      specialist = Authentication.Factory.insert(:specialist)
      _basic_info = SpecialistProfile.Factory.insert(:basic_info, specialist_id: specialist.id)
      record = EMR.Factory.insert(:automatic_record, patient_id: patient.id)

      medical_category = SpecialistProfile.Factory.insert(:medical_category)
      _ = SpecialistProfile.update_medical_categories([medical_category.id], specialist.id)

      cmd = %EMR.PatientRecords.Timeline.Commands.CreateCallItem{
        medical_category_id: medical_category.id,
        patient_id: patient.id,
        record_id: record.id,
        specialist_id: specialist.id
      }

      {:ok, call_item} = EMR.create_call_timeline_item(cmd)

      conn = get(conn, panel_timeline_path(conn, :show, record.id))

      assert %GetTimelineResponse{
               timeline: %Proto.Timeline.Timeline{
                 timeline_items: [
                   %Proto.Timeline.TimelineItem{} = returned_timeline_item
                 ]
               },
               specialists: [returned_specialist]
             } = proto_response(conn, 200, GetTimelineResponse)

      assert returned_specialist.id == specialist.id
      assert returned_timeline_item.id == call_item.id
    end
  end
end
