defmodule EMR.PatientsListTest do
  use Postgres.DataCase, async: true

  alias EMR.PatientsList

  describe "fetch/2" do
    setup do
      specialist = Authentication.Factory.insert(:specialist)
      {:ok, team} = Teams.create_team(specialist.id, %{})

      {:ok, specialist: specialist, team: team}
    end

    test "when next token is missing", %{specialist: specialist} do
      patient = PatientProfile.Factory.insert(:patient)
      _basic_info = PatientProfile.Factory.insert(:basic_info, patient_id: patient.id)
      _address = PatientProfile.Factory.insert(:address, patient_id: patient.id)

      :ok = connect(specialist.id, patient.id)

      params = %{"limit" => "1"}

      {:ok, [fetched], nil} = PatientsList.fetch(specialist.id, params)
      assert fetched.id == patient.id
    end

    test "when next token is blank string", %{specialist: specialist} do
      patient = PatientProfile.Factory.insert(:patient)
      _basic_info = PatientProfile.Factory.insert(:basic_info, patient_id: patient.id)
      _address = PatientProfile.Factory.insert(:address, patient_id: patient.id)

      :ok = connect(specialist.id, patient.id)

      params = %{"limit" => "1", "next_token" => ""}

      {:ok, [fetched], nil} = PatientsList.fetch(specialist.id, params)
      assert fetched.id == patient.id
    end

    test "when next token is valid", %{specialist: specialist} do
      patient = PatientProfile.Factory.insert(:patient)
      basic_info = PatientProfile.Factory.insert(:basic_info, patient_id: patient.id)
      _address = PatientProfile.Factory.insert(:address, patient_id: patient.id)

      :ok = connect(specialist.id, patient.id)

      params = %{"limit" => "1", "next_token" => to_string(basic_info.patient_id)}

      {:ok, [fetched], nil} = PatientsList.fetch(specialist.id, params)
      assert fetched.id == patient.id
    end

    test "returns next_token when there's more patients", %{specialist: specialist} do
      patient = PatientProfile.Factory.insert(:patient)
      basic_info = PatientProfile.Factory.insert(:basic_info, patient_id: patient.id)
      _address = PatientProfile.Factory.insert(:address, patient_id: patient.id)

      patient2 = PatientProfile.Factory.insert(:patient)
      basic_info2 = PatientProfile.Factory.insert(:basic_info, patient_id: patient2.id)
      _address2 = PatientProfile.Factory.insert(:address, patient_id: patient2.id)

      params = %{"limit" => "1", "next_token" => to_string(basic_info.patient_id)}

      :ok = connect(specialist.id, patient.id)
      :ok = connect(specialist.id, patient2.id)

      {:ok, [fetched], new_next_token} = PatientsList.fetch(specialist.id, params)
      assert fetched.id == patient.id
      assert new_next_token == basic_info2.patient_id
    end

    test "doesn't return patients without provided basic_info AND address", %{
      specialist: specialist
    } do
      patient = PatientProfile.Factory.insert(:patient)
      _basic_info = PatientProfile.Factory.insert(:basic_info, patient_id: patient.id)

      :ok = connect(specialist.id, patient.id)

      params = %{"limit" => "1"}

      {:ok, [], nil} = PatientsList.fetch(specialist.id, params)
    end

    test "returns patients when filter contains matching word", %{specialist: specialist} do
      patient = PatientProfile.Factory.insert(:patient)

      _basic_info =
        PatientProfile.Factory.insert(:basic_info, patient_id: patient.id, first_name: "Adolf")

      _address = PatientProfile.Factory.insert(:address, patient_id: patient.id)

      :ok = connect(specialist.id, patient.id)

      params = %{"limit" => "1", "filter" => "Adolf"}

      {:ok, [fetched], nil} = PatientsList.fetch(specialist.id, params)
      assert fetched.id == patient.id
    end

    test "returns patients when filter contains few matching letters", %{specialist: specialist} do
      patient = PatientProfile.Factory.insert(:patient)

      _basic_info =
        PatientProfile.Factory.insert(:basic_info, patient_id: patient.id, first_name: "Adolf")

      _address = PatientProfile.Factory.insert(:address, patient_id: patient.id)

      :ok = connect(specialist.id, patient.id)

      params = %{"limit" => "1", "filter" => "ado"}

      {:ok, [fetched], nil} = PatientsList.fetch(specialist.id, params)
      assert fetched.id == patient.id
    end

    test "returns patients when filter contains multiple matching words", %{
      specialist: specialist
    } do
      patient = PatientProfile.Factory.insert(:patient, phone_number: "+48661848585")

      _basic_info =
        PatientProfile.Factory.insert(:basic_info, patient_id: patient.id, first_name: "Adolf")

      _address = PatientProfile.Factory.insert(:address, patient_id: patient.id)

      :ok = connect(specialist.id, patient.id)

      params = %{"limit" => "1", "filter" => "adolf +48661848"}

      {:ok, [fetched], nil} = PatientsList.fetch(specialist.id, params)
      assert fetched.id == patient.id
    end

    test "doesn't return patients when filter contains not matching word", %{
      specialist: specialist
    } do
      patient = PatientProfile.Factory.insert(:patient)

      _basic_info =
        PatientProfile.Factory.insert(:basic_info, patient_id: patient.id, first_name: "Adolf")

      _address = PatientProfile.Factory.insert(:address, patient_id: patient.id)

      :ok = connect(specialist.id, patient.id)

      params = %{"limit" => "1", "filter" => "Invalid"}

      {:ok, [], nil} = PatientsList.fetch(specialist.id, params)
    end

    test "doesn't return patients when filter contains any not matching words", %{
      specialist: specialist
    } do
      patient = PatientProfile.Factory.insert(:patient, phone_number: "+48661848585")

      _basic_info =
        PatientProfile.Factory.insert(:basic_info, patient_id: patient.id, first_name: "Adolf")

      _address = PatientProfile.Factory.insert(:address, patient_id: patient.id)

      :ok = connect(specialist.id, patient.id)

      params = %{"limit" => "1", "filter" => "adolf +486619"}

      {:ok, [], nil} = PatientsList.fetch(specialist.id, params)
    end

    test "doesn't raise on multiple whitespaces in filter string", %{specialist: specialist} do
      patient = PatientProfile.Factory.insert(:patient, phone_number: "+48661848585")

      _basic_info =
        PatientProfile.Factory.insert(:basic_info, patient_id: patient.id, first_name: "Adolf")

      _address = PatientProfile.Factory.insert(:address, patient_id: patient.id)

      :ok = connect(specialist.id, patient.id)

      params = %{"limit" => "1", "filter" => "adolf +486619      "}

      {:ok, [], nil} = PatientsList.fetch(specialist.id, params)
    end
  end

  describe "fetch_ids/1" do
    setup do
      specialist = Authentication.Factory.insert(:specialist)

      patient = PatientProfile.Factory.insert(:patient)
      _basic_info = PatientProfile.Factory.insert(:basic_info, patient_id: patient.id)
      _address = PatientProfile.Factory.insert(:address, patient_id: patient.id)

      {:ok, specialist: specialist, patient: patient}
    end

    test "returns list of patient ids, that are connected to Specialist", %{
      specialist: specialist,
      patient: patient
    } do
      EMR.SpecialistPatientConnections.SpecialistPatientConnection.create(
        specialist.id,
        patient.id
      )

      assert [patient_id] = PatientsList.fetch_ids(specialist.id)
      assert patient_id == patient.id
    end

    test "returns list of patient ids, that are connected to Specialist's Team", %{
      specialist: specialist,
      patient: patient
    } do
      {:ok, team} = Teams.create_team(specialist.id, %{})
      team_member_specialist = Authentication.Factory.insert(:specialist)
      add_to_team(team_id: team.id, specialist_id: team_member_specialist.id)

      EMR.SpecialistPatientConnections.SpecialistPatientConnection.create(
        team_member_specialist.id,
        patient.id
      )

      assert [patient_id] = PatientsList.fetch_ids(specialist.id)
      assert patient_id == patient.id
    end

    test "ignores patients, connected to other team", %{
      specialist: specialist,
      patient: patient
    } do
      other_team_patient = PatientProfile.Factory.insert(:patient)
      _basic_info = PatientProfile.Factory.insert(:basic_info, patient_id: other_team_patient.id)
      _address = PatientProfile.Factory.insert(:address, patient_id: other_team_patient.id)

      other_team_specialist = Authentication.Factory.insert(:specialist)
      {:ok, other_team} = Teams.create_team(other_team_specialist.id, %{})
      add_to_team(team_id: other_team.id, specialist_id: other_team_specialist.id)

      EMR.SpecialistPatientConnections.SpecialistPatientConnection.create(
        other_team_specialist.id,
        patient.id
      )

      assert [_] = PatientsList.fetch_ids(other_team_specialist.id)
      assert [] = PatientsList.fetch_ids(specialist.id)
    end
  end

  describe "fetch_connected/2" do
    test "returns only connected patients" do
      specialist = Authentication.Factory.insert(:verified_specialist)

      patient = PatientProfile.Factory.insert(:patient)
      _basic_info = PatientProfile.Factory.insert(:basic_info, patient_id: patient.id)
      _address = PatientProfile.Factory.insert(:address, patient_id: patient.id)

      EMR.SpecialistPatientConnections.SpecialistPatientConnection.create(
        specialist.id,
        patient.id
      )

      patient2 = PatientProfile.Factory.insert(:patient)
      _basic_info2 = PatientProfile.Factory.insert(:basic_info, patient_id: patient2.id)
      _address2 = PatientProfile.Factory.insert(:address, patient_id: patient2.id)

      params = %{"limit" => "1"}

      assert {:ok, [fetched_patient], nil} = PatientsList.fetch_connected(specialist.id, params)
      assert fetched_patient.id == patient.id
    end

    test "returns patients when filter contains matching word" do
      patient = PatientProfile.Factory.insert(:patient)

      _basic_info =
        PatientProfile.Factory.insert(:basic_info, patient_id: patient.id, first_name: "Adolf")

      _address = PatientProfile.Factory.insert(:address, patient_id: patient.id)

      specialist = Authentication.Factory.insert(:specialist)

      EMR.SpecialistPatientConnections.SpecialistPatientConnection.create(
        specialist.id,
        patient.id
      )

      params = %{"limit" => "1", "filter" => "Adolf"}

      {:ok, [fetched], nil} = PatientsList.fetch_connected(specialist.id, params)
      assert fetched.id == patient.id
    end

    test "returns patients when filter contains few matching letters" do
      patient = PatientProfile.Factory.insert(:patient)

      _basic_info =
        PatientProfile.Factory.insert(:basic_info, patient_id: patient.id, first_name: "Adolf")

      _address = PatientProfile.Factory.insert(:address, patient_id: patient.id)

      specialist = Authentication.Factory.insert(:specialist)

      EMR.SpecialistPatientConnections.SpecialistPatientConnection.create(
        specialist.id,
        patient.id
      )

      params = %{"limit" => "1", "filter" => "ado"}

      {:ok, [fetched], nil} = PatientsList.fetch_connected(specialist.id, params)
      assert fetched.id == patient.id
    end

    test "returns patients when filter contains multiple matching words" do
      patient = PatientProfile.Factory.insert(:patient, phone_number: "+48661848585")

      _basic_info =
        PatientProfile.Factory.insert(:basic_info, patient_id: patient.id, first_name: "Adolf")

      _address = PatientProfile.Factory.insert(:address, patient_id: patient.id)

      specialist = Authentication.Factory.insert(:specialist)

      EMR.SpecialistPatientConnections.SpecialistPatientConnection.create(
        specialist.id,
        patient.id
      )

      params = %{"limit" => "1", "filter" => "adolf +48661848585"}

      {:ok, [fetched], nil} = PatientsList.fetch_connected(specialist.id, params)
      assert fetched.id == patient.id
    end

    test "doesn't return patients when filter contains not matching word" do
      patient = PatientProfile.Factory.insert(:patient)

      _basic_info =
        PatientProfile.Factory.insert(:basic_info, patient_id: patient.id, first_name: "Adolf")

      _address = PatientProfile.Factory.insert(:address, patient_id: patient.id)

      specialist = Authentication.Factory.insert(:specialist)

      EMR.SpecialistPatientConnections.SpecialistPatientConnection.create(
        specialist.id,
        patient.id
      )

      params = %{"limit" => "1", "filter" => "Invalid"}

      {:ok, [], nil} = PatientsList.fetch_connected(specialist.id, params)
    end

    test "doesn't return patients when filter contains any not matching words" do
      patient = PatientProfile.Factory.insert(:patient, phone_number: "+48661848585")

      _basic_info =
        PatientProfile.Factory.insert(:basic_info, patient_id: patient.id, first_name: "Adolf")

      _address = PatientProfile.Factory.insert(:address, patient_id: patient.id, city: "Berlin")

      specialist = Authentication.Factory.insert(:specialist)

      EMR.SpecialistPatientConnections.SpecialistPatientConnection.create(
        specialist.id,
        patient.id
      )

      params = %{"limit" => "1", "filter" => "adolf +496618484585"}

      {:ok, [], nil} = PatientsList.fetch_connected(specialist.id, params)
    end
  end

  defp connect(specialist_id, patient_id) do
    {:ok, _} =
      EMR.SpecialistPatientConnections.SpecialistPatientConnection.create(
        specialist_id,
        patient_id
      )

    :ok
  end

  defp add_to_team(opts) do
    :ok = Teams.add_to_team(opts)
    Teams.accept_invitation(opts)
  end
end
