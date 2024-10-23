defmodule Web.Api.Patient.CredentialsControllerTest do
  use Web.ConnCase, async: true

  alias Proto.PatientProfile.Credentials
  alias Proto.PatientProfile.GetCredentialsResponse

  setup(opts) do
    {:ok, %{conn: conn, current_patient: current_patient}} =
      authenticate_patient(opts)

    %{patient_id: current_patient.id, conn: conn}
  end

  describe "GET show" do
    test "success", %{conn: conn, patient_id: patient_id} do
      conn = get(conn, patient_credentials_path(conn, :show))

      assert %GetCredentialsResponse{
               credentials: %Credentials{id: ^patient_id}
             } = proto_response(conn, 200, GetCredentialsResponse)
    end
  end
end
