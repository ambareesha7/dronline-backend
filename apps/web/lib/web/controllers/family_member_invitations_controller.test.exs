defmodule Web.PublicApi.FamilyMemberInvitationsControllerTest do
  use Web.ConnCase, async: true

  alias Calls.FamilyMemberInvitations.Create
  alias Proto.Calls.FamilyMemberInvitation
  alias Proto.Calls.GetFamilyMemberInvitationResponse

  describe "GET" do
    test "GET /family_member_invitations/EXISTING_ID returns 200", %{
      conn: conn
    } do
      patient = PatientProfile.Factory.insert(:patient)

      _basic_info =
        PatientProfile.Factory.insert(:basic_info, patient_id: patient.id, first_name: "Adolf")

      {:ok, invitation} =
        Create.call(patient.id, %{
          call_id: "call_id",
          session_id: "session_id",
          phone_number: "+38012345678",
          name: "First Last"
        })

      resp = get(conn, family_member_invitations_path(conn, :show, invitation.id))

      assert %GetFamilyMemberInvitationResponse{
               api_key: _,
               invitation: %FamilyMemberInvitation{
                 id: invitation_id
               }
             } = proto_response(resp, 200, GetFamilyMemberInvitationResponse)

      assert invitation_id == invitation.id
    end
  end
end
