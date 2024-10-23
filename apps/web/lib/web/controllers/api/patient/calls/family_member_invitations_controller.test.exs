defmodule Web.Api.FamilyMemberInvitationsControllerTest do
  use Web.ConnCase, async: true

  alias Proto.Calls.CreateFamilyMemberInvitationRequest

  describe "POST" do
    setup [:proto_content, :authenticate_patient]

    @tag runnable: true
    test "POST /family_member_invitations creates invitation", %{
      conn: conn
    } do
      proto =
        %{
          call_id: "call_id",
          session_id: "session_id",
          phone_number: "+38012345678",
          name: "First Last"
        }
        |> CreateFamilyMemberInvitationRequest.new()
        |> CreateFamilyMemberInvitationRequest.encode()

      conn = post(conn, calls_family_member_invitations_path(conn, :create), proto)

      assert response(conn, 201)
    end
  end
end
