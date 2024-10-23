defmodule Web.Api.EMR.MedicalSummariesControllerTest do
  use Web.ConnCase, async: true

  alias Proto.EMR.GetMedicalSummariesResponse
  alias Proto.EMR.GetMedicalSummaryResponse

  describe "GET index" do
    setup [:authenticate_patient]

    test "succeeds", %{conn: conn, current_patient: current_patient} do
      specialist = Authentication.Factory.insert(:verified_specialist)
      _basic_info = SpecialistProfile.Factory.insert(:basic_info, specialist_id: specialist.id)

      timeline = EMR.Factory.insert(:automatic_record, patient_id: current_patient.id)

      _ =
        EMR.Factory.insert(:medical_summary,
          specialist_id: specialist.id,
          timeline_id: timeline.id
        )

      conn = get(conn, emr_medical_summaries_path(conn, :index, timeline.id))

      assert %GetMedicalSummariesResponse{medical_summaries: [_]} =
               proto_response(conn, 200, GetMedicalSummariesResponse)
    end
  end

  describe "GET show" do
    setup [:authenticate_patient]

    test "succeeds", %{conn: conn, current_patient: current_patient} do
      specialist = Authentication.Factory.insert(:verified_specialist)
      _basic_info = SpecialistProfile.Factory.insert(:basic_info, specialist_id: specialist.id)

      timeline = EMR.Factory.insert(:automatic_record, patient_id: current_patient.id)

      medical_summary =
        EMR.Factory.insert(:medical_summary,
          specialist_id: specialist.id,
          timeline_id: timeline.id
        )

      conn = get(conn, emr_medical_summaries_path(conn, :show, timeline.id, medical_summary.id))

      assert %GetMedicalSummaryResponse{
               medical_summary: %Proto.EMR.MedicalSummary{
                 specialist_id: specialist_id
               },
               specialist: %Proto.Generics.Specialist{
                 id: specialist_id
               }
             } = proto_response(conn, 200, GetMedicalSummaryResponse)
    end
  end
end
