defmodule Calls.DoctorCategoryInvitations.Commands do
  alias Calls.DoctorCategoryInvitations

  import Mockery.Macro

  defmacrop channel_broadcast do
    quote do: mockable(Calls.ChannelBroadcast, by: Calls.ChannelBroadcastMock)
  end

  defmacrop notification do
    quote do: mockable(PushNotifications.Message)
  end

  def invite_doctor_category(%Calls.DoctorCategoryInvitations.Commands.InviteCategory{} = cmd) do
    team_id = Teams.specialist_team_id(cmd.invited_by_specialist_id)

    params = cmd |> Map.from_struct() |> Map.put(:team_id, team_id)

    with {:ok, invitation} <- DoctorCategoryInvitations.invite_category(params) do
      timeline_item_cmd = %EMR.PatientRecords.Timeline.Commands.CreateDoctorInvitationItem{
        medical_category_id: cmd.category_id,
        patient_id: cmd.patient_id,
        record_id: cmd.record_id,
        specialist_id: cmd.invited_by_specialist_id
      }

      _ = EMR.create_doctor_invitation_timeline_item(timeline_item_cmd)
      _ = broadcast_invitations_update(invitation.category_id)

      notification().send(%PushNotifications.Message.DoctorCategoryInvitation{
        specialist_ids:
          SpecialistProfile.get_specialist_ids_for_medical_category(invitation.category_id)
      })
    end
  end

  def cancel_invitation(%Calls.DoctorCategoryInvitations.Commands.CancelInvitation{} = cmd) do
    with {:ok, invitation} <-
           DoctorCategoryInvitations.delete_invitation(cmd.call_id, cmd.category_id) do
      _ = broadcast_invitations_update(invitation.category_id)
    else
      _ -> :ok
    end
  end

  def accept_invitation(%Calls.DoctorCategoryInvitations.Commands.AcceptInvitation{} = cmd) do
    with {:ok, invitation} <-
           DoctorCategoryInvitations.delete_invitation(cmd.call_id, cmd.category_id) do
      _ = send_call_session_to_doctor(cmd, invitation)
      _ = EMR.register_interaction_between(cmd.doctor_id, invitation.patient_id)
      _ = broadcast_invitations_update(invitation.category_id)
      _ = create_call_timeline_item(cmd, invitation)

      _ =
        EMR.PatientRecords.MedicalSummary.PendingSummary.create(
          invitation.patient_id,
          invitation.record_id,
          cmd.doctor_id
        )

      :ok
    else
      _ -> {:error, :invalid_invitation}
    end
  end

  defp broadcast_invitations_update(category_id) do
    channel_broadcast().broadcast({:doctor_category_invitations_update, category_id})
  end

  defp send_call_session_to_doctor(cmd, invitation) do
    %{
      call_id: call_id,
      session_id: session_id,
      record_id: record_id,
      patient_id: patient_id
    } = invitation

    token = OpenTok.generate_session_token(invitation.session_id)

    for topic <- ["doctor", "external"] do
      channel_broadcast().push(%{
        topic: topic,
        event: "call_established",
        payload: %{
          data: %{
            token: token,
            session_id: session_id,
            patient_id: patient_id,
            record_id: record_id,
            api_key: Application.get_env(:opentok, :api_key),
            call_id: call_id
          },
          doctor_id: cmd.doctor_id
        }
      })
    end
  end

  defp create_call_timeline_item(cmd, invitation) do
    cmd = %EMR.PatientRecords.Timeline.Commands.CreateCallItem{
      medical_category_id: invitation.category_id,
      patient_id: invitation.patient_id,
      record_id: invitation.record_id,
      specialist_id: cmd.doctor_id
    }

    EMR.create_call_timeline_item(cmd)
  end
end
