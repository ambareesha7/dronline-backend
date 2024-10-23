defmodule Web.PanelApi.EMR.InvitationsControllerTest do
  use Web.ConnCase, async: true

  alias Proto.EMR.Invitation
  alias Proto.EMR.InvitePatientRequest

  describe "POST create" do
    setup [:authenticate_external, :proto_content]

    test "succeeds", %{conn: conn, current_external: current_external} do
      SpecialistProfile.Factory.insert(:basic_info, specialist_id: current_external.id)

      invitation_proto =
        %{
          invitation:
            Invitation.new(%{
              title: :MR |> Proto.Generics.Title.value(),
              first_name: "First name",
              last_name: "Last name",
              phone_number: "+48532568641",
              email: "test@exmaple.com"
            })
        }
        |> Proto.validate!(InvitePatientRequest)
        |> InvitePatientRequest.new()
        |> InvitePatientRequest.encode()

      conn = post(conn, panel_emr_invitations_path(conn, :create), invitation_proto)

      assert response(conn, 201)
    end
  end
end
