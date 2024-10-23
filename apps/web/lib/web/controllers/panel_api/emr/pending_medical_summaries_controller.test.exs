defmodule Web.PanelApi.EMR.PendingMedicalSummariesControllerTest do
  use Web.ConnCase, async: true

  alias Proto.EMR.GetPendingMedicalSummaryResponse

  describe "GET index" do
    setup [:authenticate_gp]

    test "returns pending medical summary data when summary is pending, also returns draft if present",
         %{
           conn: conn,
           current_gp: current_gp
         } do
      {:ok, :created} =
        EMR.PatientRecords.MedicalSummary.PendingSummary.create(1337, 666, current_gp.id)

      conn = get(conn, panel_emr_pending_medical_summaries_path(conn, :show))

      assert %GetPendingMedicalSummaryResponse{
               pending_medical_summary: %GetPendingMedicalSummaryResponse.PendingMedicalSummary{
                 record_id: record_id,
                 patient_id: patient_id
               }
             } = proto_response(conn, 200, GetPendingMedicalSummaryResponse)

      assert record_id == 666
      assert patient_id == 1337
    end

    test "returns empty response when there's no pending summary", %{conn: conn} do
      conn = get(conn, panel_emr_pending_medical_summaries_path(conn, :show))

      assert %GetPendingMedicalSummaryResponse{
               pending_medical_summary: nil
             } = proto_response(conn, 200, GetPendingMedicalSummaryResponse)
    end
  end
end
