defmodule Web.PublicApi.FamilyMemberInvitationsController do
  use Web, :controller

  alias Calls.FamilyMemberInvitation

  def show(conn, %{"id" => id}) do
    with {:ok, invitation} <- FamilyMemberInvitation.fetch_by_id(id) do
      patient_generic_data = Web.PatientGenericData.get_by_id(invitation.patient_id)

      render(conn, "show.proto", %{
        invitation: invitation,
        patient_generic_data: patient_generic_data
      })
    end
  end
end

defmodule Web.PublicApi.FamilyMemberInvitationsView do
  use Web, :view

  def render("show.proto", %{
        invitation: invitation,
        patient_generic_data: patient_generic_data
      }) do
    %Proto.Calls.GetFamilyMemberInvitationResponse{
      api_key: api_key(),
      invitation: %Proto.Calls.FamilyMemberInvitation{
        id: invitation.id,
        call_id: invitation.call_id,
        name: invitation.name,
        phone_number: invitation.phone_number,
        session_id: invitation.session_id,
        session_token: invitation.session_token
      },
      patient: Web.View.Generics.render_patient(patient_generic_data)
    }
  end

  defp api_key, do: Application.get_env(:opentok, :api_key)
end
