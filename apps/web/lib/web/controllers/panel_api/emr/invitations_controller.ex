defmodule Web.PanelApi.EMR.InvitationsController do
  use Conductor
  use Web, :controller

  action_fallback Web.FallbackController

  @authorize scopes: ["GP", "NURSE", "EXTERNAL"]
  @decode Proto.EMR.InvitePatientRequest
  def create(conn, _params) do
    specialist_id = conn.assigns.current_specialist_id
    invitation_proto = conn.assigns.protobuf.invitation

    with {:ok, _job} <- EMR.create_invitation(specialist_id, invitation_proto) do
      send_resp(conn, 201, "")
    end
  end
end
