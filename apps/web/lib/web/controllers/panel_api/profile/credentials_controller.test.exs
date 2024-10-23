defmodule Web.PanelApi.Profile.CredentialsControllerTest do
  use Web.ConnCase, async: true

  alias Proto.SpecialistProfile.GetCredentialsResponse

  alias Proto.SpecialistProfile.Credentials

  describe "GET show" do
    setup [:authenticate_gp]

    test "success when payment info doesn't exist", %{conn: conn, current_gp: gp} do
      conn = get(conn, panel_profile_credentials_path(conn, :show))

      assert %GetCredentialsResponse{credentials: %Credentials{} = credentials} =
               proto_response(conn, 200, GetCredentialsResponse)

      assert credentials.email == gp.email
      assert credentials.id == gp.id
    end
  end
end
