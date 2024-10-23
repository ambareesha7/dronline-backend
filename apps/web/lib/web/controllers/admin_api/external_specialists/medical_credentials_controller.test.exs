defmodule Web.AdminApi.ExternalSpecialists.MedicalCredentialsControllerTest do
  use Web.ConnCase, async: true

  alias Proto.SpecialistProfile.GetMedicalCredentialsResponse

  alias Proto.SpecialistProfile.MedicalCredentials

  describe "GET show" do
    setup [:authenticate_admin]

    test "success when medical_credentials doesn't exist", %{conn: conn} do
      specialist = Authentication.Factory.insert(:verified_specialist, type: "EXTERNAL")

      conn =
        get(conn, admin_external_specialists_medical_credentials_path(conn, :show, specialist.id))

      assert %GetMedicalCredentialsResponse{medical_credentials: %MedicalCredentials{}} =
               proto_response(conn, 200, GetMedicalCredentialsResponse)
    end

    test "success when medical_credentials exists", %{conn: conn} do
      specialist = Authentication.Factory.insert(:verified_specialist, type: "EXTERNAL")

      _medical_credentials =
        SpecialistProfile.Factory.insert(:medical_credentials,
          specialist_id: specialist.id,
          dea_number_url: "dea_url"
        )

      conn =
        get(conn, admin_external_specialists_medical_credentials_path(conn, :show, specialist.id))

      assert %GetMedicalCredentialsResponse{
               medical_credentials: %MedicalCredentials{dea_number_url: "dea_url"}
             } = proto_response(conn, 200, GetMedicalCredentialsResponse)
    end
  end
end
