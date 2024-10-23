defmodule Web.Api.Calls.FamilyMemberInvitationsController do
  use Web, :controller

  alias Calls.FamilyMemberInvitations.Create

  @decode Proto.Calls.CreateFamilyMemberInvitationRequest
  def create(conn, _params) do
    patient_id = conn.assigns.current_patient_id
    proto = conn.assigns.protobuf

    with {:ok, _invitation} <-
           Create.call(patient_id, %{
             call_id: proto.call_id,
             session_id: proto.session_id,
             phone_number: proto.phone_number,
             name: proto.name
           }) do
      send_resp(conn, 201, "")
    end
  end
end
