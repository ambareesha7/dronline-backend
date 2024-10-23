defmodule Calls.DoctorCategoryInvitations.CommandsTest do
  use Postgres.DataCase, async: true

  import Mockery.Assertions

  alias Calls.DoctorCategoryInvitations

  defp prepare_invite_command(category_id) do
    patient = PatientProfile.Factory.insert(:patient)
    nurse = Authentication.Factory.insert(:specialist, type: "NURSE")
    {:ok, team} = Teams.create_team(random_id(), %{})
    :ok = add_to_team(team_id: team.id, specialist_id: nurse.id)

    _basic_info = SpecialistProfile.Factory.insert(:basic_info, specialist_id: nurse.id)
    record = EMR.Factory.insert(:automatic_record, patient_id: patient.id)

    %DoctorCategoryInvitations.Commands.InviteCategory{
      invited_by_specialist_id: nurse.id,
      patient_id: patient.id,
      record_id: record.id,
      call_id: UUID.uuid4(),
      session_id: UUID.uuid4(),
      category_id: category_id
    }
  end

  defp prepare_cancel_invitation_command(call_id, category_id) do
    %DoctorCategoryInvitations.Commands.CancelInvitation{
      category_id: category_id,
      call_id: call_id
    }
  end

  defp prepare_accept_invitation_command(call_id, category_id) do
    doctor = Authentication.Factory.insert(:verified_and_approved_external, type: "EXTERNAL")

    %DoctorCategoryInvitations.Commands.AcceptInvitation{
      doctor_id: doctor.id,
      call_id: call_id,
      category_id: category_id
    }
  end

  describe "invite_doctor_category/1" do
    test "create doctor category invitation" do
      doctor_category_id = VisitsScheduling.Factory.insert(:medical_category).id
      cmd = prepare_invite_command(doctor_category_id)

      assert :ok = DoctorCategoryInvitations.Commands.invite_doctor_category(cmd)

      assert {:ok, [invitation]} =
               Calls.DoctorCategoryInvitations.fetch_invitations(
                 cmd.invited_by_specialist_id,
                 doctor_category_id
               )

      assert invitation.invited_by_specialist_id == cmd.invited_by_specialist_id
    end

    test "only specialists from the same team are invited" do
    end

    test "doesn't allow to invited the same category for one call twice" do
      doctor_category_id = VisitsScheduling.Factory.insert(:medical_category).id
      cmd = prepare_invite_command(doctor_category_id)

      assert :ok = DoctorCategoryInvitations.Commands.invite_doctor_category(cmd)

      assert {:ok, [invitation]} =
               Calls.DoctorCategoryInvitations.fetch_invitations(
                 cmd.invited_by_specialist_id,
                 doctor_category_id
               )

      assert invitation.invited_by_specialist_id == cmd.invited_by_specialist_id

      assert {:error, changeset} = DoctorCategoryInvitations.Commands.invite_doctor_category(cmd)

      assert {"the category of doctors have been invited already", _details} =
               Keyword.get(changeset.errors, :_invitation)
    end

    test "broadcast queue update on success" do
      doctor_category_id = VisitsScheduling.Factory.insert(:medical_category).id
      cmd = prepare_invite_command(doctor_category_id)

      :ok = DoctorCategoryInvitations.Commands.invite_doctor_category(cmd)

      assert_called(Calls.ChannelBroadcast, :broadcast, [
        {:doctor_category_invitations_update, ^doctor_category_id}
      ])
    end
  end

  describe "cancel_invitation/1" do
    test "removes invitation" do
      doctor_category_id = VisitsScheduling.Factory.insert(:medical_category).id
      cmd = prepare_invite_command(doctor_category_id)

      assert :ok = DoctorCategoryInvitations.Commands.invite_doctor_category(cmd)

      assert {:ok, [invitation]} =
               DoctorCategoryInvitations.fetch_invitations(
                 cmd.invited_by_specialist_id,
                 doctor_category_id
               )

      assert invitation.invited_by_specialist_id == cmd.invited_by_specialist_id

      cancel_cmd = prepare_cancel_invitation_command(cmd.call_id, doctor_category_id)
      assert :ok = DoctorCategoryInvitations.Commands.cancel_invitation(cancel_cmd)

      assert {:ok, []} =
               DoctorCategoryInvitations.fetch_invitations(
                 cmd.invited_by_specialist_id,
                 doctor_category_id
               )
    end

    test "returns ok when there is no invitation" do
      doctor_category_id = VisitsScheduling.Factory.insert(:medical_category).id
      cmd = prepare_cancel_invitation_command("call_id", doctor_category_id)

      assert :ok = DoctorCategoryInvitations.Commands.cancel_invitation(cmd)
    end

    test "broadcasts update on success" do
      doctor_category_id = VisitsScheduling.Factory.insert(:medical_category).id
      cmd = prepare_invite_command(doctor_category_id)

      :ok = DoctorCategoryInvitations.Commands.invite_doctor_category(cmd)

      cmd = prepare_cancel_invitation_command(cmd.call_id, doctor_category_id)
      :ok = DoctorCategoryInvitations.Commands.cancel_invitation(cmd)

      assert_called(Calls.ChannelBroadcast, :broadcast, [
        {:doctor_category_invitations_update, ^doctor_category_id}
      ])
    end
  end

  describe "accept_invitation/1" do
    test "removes invitation" do
      doctor_category_id = VisitsScheduling.Factory.insert(:medical_category).id
      cmd = prepare_invite_command(doctor_category_id)

      assert :ok = DoctorCategoryInvitations.Commands.invite_doctor_category(cmd)

      assert {:ok, [invitation]} =
               DoctorCategoryInvitations.fetch_invitations(
                 cmd.invited_by_specialist_id,
                 doctor_category_id
               )

      assert invitation.invited_by_specialist_id == cmd.invited_by_specialist_id

      accept_cmd = prepare_accept_invitation_command(cmd.call_id, doctor_category_id)
      assert :ok = DoctorCategoryInvitations.Commands.accept_invitation(accept_cmd)

      assert {:ok, []} =
               DoctorCategoryInvitations.fetch_invitations(
                 cmd.invited_by_specialist_id,
                 doctor_category_id
               )
    end

    test "returns error when the nurse isn't in queue" do
      doctor_category_id = VisitsScheduling.Factory.insert(:medical_category).id
      cmd = prepare_accept_invitation_command("call_id", doctor_category_id)

      assert {:error, :invalid_invitation} =
               DoctorCategoryInvitations.Commands.accept_invitation(cmd)
    end

    test "broadcasts update on success" do
      doctor_category_id = VisitsScheduling.Factory.insert(:medical_category).id
      cmd = prepare_invite_command(doctor_category_id)

      :ok = DoctorCategoryInvitations.Commands.invite_doctor_category(cmd)

      cmd = prepare_accept_invitation_command(cmd.call_id, doctor_category_id)
      :ok = DoctorCategoryInvitations.Commands.accept_invitation(cmd)

      assert_called(Calls.ChannelBroadcast, :broadcast, [
        {:doctor_category_invitations_update, ^doctor_category_id}
      ])
    end

    test "pushes message to doctor on success" do
      doctor_category_id = VisitsScheduling.Factory.insert(:medical_category).id
      cmd = prepare_invite_command(doctor_category_id)

      :ok = DoctorCategoryInvitations.Commands.invite_doctor_category(cmd)

      cmd = prepare_accept_invitation_command(cmd.call_id, doctor_category_id)
      :ok = DoctorCategoryInvitations.Commands.accept_invitation(cmd)

      doctor_id = cmd.doctor_id

      assert_called(Calls.ChannelBroadcast, :push, [
        %{topic: "doctor", payload: %{doctor_id: ^doctor_id}}
      ])
    end

    test "creates patient-specialist connection on success" do
      doctor_category_id = VisitsScheduling.Factory.insert(:medical_category).id
      cmd1 = prepare_invite_command(doctor_category_id)

      :ok = DoctorCategoryInvitations.Commands.invite_doctor_category(cmd1)

      cmd2 = prepare_accept_invitation_command(cmd1.call_id, doctor_category_id)
      :ok = DoctorCategoryInvitations.Commands.accept_invitation(cmd2)

      patient_id = cmd1.patient_id
      doctor_id = cmd2.doctor_id

      assert EMR.specialist_connected_with_patient?(doctor_id, patient_id)
    end
  end

  defp add_to_team(opts) do
    :ok = Teams.add_to_team(opts)
    Teams.accept_invitation(opts)
  end

  defp random_id, do: :rand.uniform(1000)
end
