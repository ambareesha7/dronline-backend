defmodule Web.AdminApi.ExternalSpecialists.CredentialsControllerTest do
  use Web.ConnCase, async: true

  alias Proto.SpecialistProfile.GetCredentialsResponse

  alias Proto.SpecialistProfile.Credentials

  describe "GET show" do
    setup [:authenticate_admin]

    test "success when payment info doesn't exist", %{conn: conn} do
      specialist = Authentication.Factory.insert(:verified_specialist, type: "EXTERNAL")

      conn = get(conn, admin_external_specialists_credentials_path(conn, :show, specialist.id))

      assert %GetCredentialsResponse{credentials: %Credentials{} = credentials} =
               proto_response(conn, 200, GetCredentialsResponse)

      assert credentials.email == specialist.email
    end
  end
end
