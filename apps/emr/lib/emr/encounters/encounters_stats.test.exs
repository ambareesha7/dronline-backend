defmodule EMR.Encounters.EncountersStatsTest do
  use Postgres.DataCase, async: true

  alias EMR.Encounters.EncountersStats

  describe "get_for_specialist/1" do
    test "return empty encounters stats" do
      assert %{canceled: 0, completed: 0, pending: 0, scheduled: 0} =
               EncountersStats.get_for_specialist(1)
    end

    test "return encounters stats, filtered by specialist" do
      patient = PatientProfile.Factory.insert(:patient)
      specialist = Authentication.Factory.insert(:verified_and_approved_external)
      ignored_specialist = Authentication.Factory.insert(:verified_and_approved_external)

      insert_records(patient, specialist, ignored_specialist)

      assert %{canceled: 1, completed: 1, pending: 2, scheduled: 3} =
               EncountersStats.get_for_specialist(specialist.id)
    end
  end

  describe "get_for_team/1" do
    test "return encounters stats, filtered by team" do
      patient = PatientProfile.Factory.insert(:patient)
      specialist = Authentication.Factory.insert(:verified_and_approved_external)
      ignored_specialist = Authentication.Factory.insert(:verified_and_approved_external)

      insert_records(patient, specialist, ignored_specialist)

      {:ok, %{id: team_id}} = Teams.create_team(random_id(), %{})
      :ok = add_to_team(team_id: team_id, specialist_id: specialist.id)

      assert %{canceled: 1, completed: 1, pending: 2, scheduled: 3} =
               EncountersStats.get_for_team(team_id)
    end
  end

  describe "get_urgent_care_stats_for_team/1" do
    test "return urgent care calls stats, filtered by team" do
      patient = PatientProfile.Factory.insert(:patient)
      specialist = Authentication.Factory.insert(:verified_and_approved_external)
      ignored_specialist = Authentication.Factory.insert(:verified_and_approved_external)

      insert_records(patient, specialist, ignored_specialist)

      {:ok, %{id: team_id}} = Teams.create_team(random_id(), %{})
      :ok = add_to_team(team_id: team_id, specialist_id: specialist.id)

      assert %{total: 1} = EncountersStats.get_urgent_care_stats_for_team(team_id)
    end
  end

  defp insert_records(patient, specialist, ignored_specialist) do
    _ignored_completed_record =
      EMR.Factory.insert(
        :completed_record,
        patient_id: patient.id,
        specialist_id: ignored_specialist.id,
        type: :AUTO
      )

    _completed_record =
      EMR.Factory.insert(
        :completed_record,
        patient_id: patient.id,
        specialist_id: specialist.id,
        type: :AUTO
      )

    _canceled_record =
      EMR.Factory.insert(
        :canceled_record,
        patient_id: patient.id,
        specialist_id: specialist.id,
        type: :VISIT
      )

    _active_record =
      EMR.Factory.insert(
        :active_record,
        patient_id: patient.id,
        specialist_id: specialist.id,
        type: :IN_OFFICE
      )

    _active_record =
      EMR.Factory.insert(
        :active_record,
        patient_id: patient.id,
        specialist_id: specialist.id,
        type: :US_BOARD
      )
  end

  defp add_to_team(opts) do
    :ok = Teams.add_to_team(opts)
    Teams.accept_invitation(opts)
  end

  defp random_id, do: :rand.uniform(1000)
end
