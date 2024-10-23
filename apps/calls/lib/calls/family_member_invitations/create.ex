defmodule Calls.FamilyMemberInvitations.Create do
  use Postgres.Service

  import Mockery.Macro

  alias Calls.FamilyMemberInvitation

  @spec call(pos_integer, map) ::
          {:ok, %FamilyMemberInvitation{}} | {:error, Ecto.Changeset.t()} | {:error, String.t()}
  def call(patient_id, invitation_proto) do
    params =
      Map.merge(
        invitation_proto,
        %{
          patient_id: patient_id,
          session_token: OpenTok.generate_session_token(invitation_proto.session_id)
        }
      )

    with {:ok, patient_basic_info} <- PatientProfile.fetch_basic_info(patient_id),
         {:ok, invitation} <- FamilyMemberInvitation.create(params),
         {:ok, dynamic_link} <-
           Firebase.dynamic_link(
             invitation_url(invitation.id),
             app_name: :patient,
             fallback_link: invitation_url(invitation.id)
           ),
         :ok <- send_sms(invitation, dynamic_link, patient_basic_info) do
      {:ok, invitation}
    end
  end

  defp send_sms(%{phone_number: ""}, _, _), do: :ok
  defp send_sms(%{phone_number: nil}, _, _), do: :ok

  defp send_sms(invitation, dynamic_link, patient_basic_info) do
    body =
      "Patient #{patient_basic_info.first_name} #{patient_basic_info.last_name} invites you " <>
        "to join a Call on DrOnline #{dynamic_link}"

    resp =
      mockable(Twilio.SMSClient, by: Twilio.SMSClientMock).send(
        invitation.phone_number,
        body
      )

    case resp do
      :ok ->
        :ok

      {:error, {:ok, %Tesla.Env{body: %{"message" => message}}}} ->
        {:error, message}
    end
  end

  defp invitation_url(invitation_id) do
    :web
    |> Application.get_env(:specialist_panel_url)
    |> Path.join("call-invitation")
    |> Path.join(invitation_id)
  end
end
