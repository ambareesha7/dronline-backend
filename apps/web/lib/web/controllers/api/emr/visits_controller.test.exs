defmodule Web.Api.EMR.VisitsControllerTest do
  use Web.ConnCase, async: true

  alias Proto.EMR.GetRecordVisitsResponse

  describe "GET index" do
    setup [:authenticate_patient]

    test "succeeds", %{conn: conn, current_patient: current_patient} do
      specialist = Authentication.Factory.insert(:verified_specialist)
      record = EMR.Factory.insert(:automatic_record, patient_id: current_patient.id)

      {:ok, visit} =
        Visits.PendingVisit.create(%{
          chosen_medical_category_id: 1,
          patient_id: current_patient.id,
          record_id: record.id,
          specialist_id: specialist.id,
          start_time: 0,
          visit_type: :ONLINE
        })

      conn = get(conn, emr_visits_path(conn, :index, record.id))

      assert %GetRecordVisitsResponse{visits: [fetched]} =
               proto_response(conn, 200, GetRecordVisitsResponse)

      assert fetched.start_time == visit.start_time
      assert fetched.specialist_id == visit.specialist_id
    end
  end
end
