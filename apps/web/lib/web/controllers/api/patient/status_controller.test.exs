defmodule Web.Api.Patient.StatusControllerTest do
  use Web.ConnCase, async: true

  alias Proto.PatientProfile.GetStatusResponse

  describe "GET show" do
    setup [:authenticate_patient]

    test "success", %{conn: conn} do
      conn = get(conn, patient_status_path(conn, :show))

      %GetStatusResponse{onboarding_completed: false} =
        proto_response(conn, 200, GetStatusResponse)
    end
  end
end
