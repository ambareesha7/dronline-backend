defmodule Calls.DoctorCategoryInvitationsTest do
  use Postgres.DataCase, async: true

  describe "fetch_invitations/1" do
    test "returns all invitations for given category with the oldest first" do
      patient1 = PatientProfile.Factory.insert(:patient)
      nurse1 = Authentication.Factory.insert(:specialist, type: "NURSE")
      record1 = EMR.Factory.insert(:automatic_record, patient_id: patient1.id)

      patient2 = PatientProfile.Factory.insert(:patient)
      nurse2 = Authentication.Factory.insert(:specialist, type: "NURSE")
      record2 = EMR.Factory.insert(:automatic_record, patient_id: patient2.id)

      {:ok, team} = Teams.create_team(random_id(), %{})
      :ok = add_to_team(team_id: team.id, specialist_id: nurse1.id)
      :ok = add_to_team(team_id: team.id, specialist_id: nurse2.id)

      params = %{
        invited_by_specialist_id: nurse1.id,
        patient_id: patient1.id,
        record_id: record1.id,
        call_id: "call_id1",
        session_id: "session_id1",
        category_id: 0,
        team_id: team.id
      }

      {:ok, _pending_call} = Calls.DoctorCategoryInvitations.invite_category(params)

      params = %{
        invited_by_specialist_id: nurse2.id,
        patient_id: patient2.id,
        record_id: record2.id,
        call_id: "call_id2",
        session_id: "session_id2",
        category_id: 0,
        team_id: team.id
      }

      {:ok, _pending_call} = Calls.DoctorCategoryInvitations.invite_category(params)

      assert {:ok, [entry1, entry2]} =
               Calls.DoctorCategoryInvitations.fetch_invitations(nurse1.id, 0)

      assert entry1.invited_by_specialist_id == nurse1.id
      assert entry2.invited_by_specialist_id == nurse2.id
    end
  end

  defp add_to_team(opts) do
    :ok = Teams.add_to_team(opts)
    Teams.accept_invitation(opts)
  end

  defp random_id, do: :rand.uniform(1000)
end
