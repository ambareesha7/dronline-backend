defmodule EMR.SpecialistPatientConnections.SpecialistPatientConnectionTest do
  use Postgres.DataCase, async: true

  alias EMR.SpecialistPatientConnections.SpecialistPatientConnection

  describe "create/2" do
    test "succeeds when inserting for the second time" do
      specialist = Authentication.Factory.insert(:verified_specialist)
      patient = PatientProfile.Factory.insert(:patient)

      assert {:ok, %SpecialistPatientConnection{}} =
               SpecialistPatientConnection.create(specialist.id, patient.id)

      assert {:ok, %SpecialistPatientConnection{id: nil}} =
               SpecialistPatientConnection.create(specialist.id, patient.id)
    end

    test "team_id is saved on the connection" do
      specialist = Authentication.Factory.insert(:verified_specialist)
      patient = PatientProfile.Factory.insert(:patient)

      {:ok, %{id: team_id}} = Teams.create_team(specialist.id, %{})

      assert {:ok, %SpecialistPatientConnection{team_id: ^team_id}} =
               SpecialistPatientConnection.create(specialist.id, patient.id)
    end
  end

  describe "specialist_patient_connected?/3" do
    test "returns true when patient is connected with specialist (via_timeline false)" do
      specialist = Authentication.Factory.insert(:verified_specialist)
      patient = PatientProfile.Factory.insert(:patient)

      SpecialistPatientConnection.create(specialist.id, patient.id)

      assert SpecialistPatientConnection.specialist_patient_connected?(
               specialist.id,
               patient.id,
               false
             )
    end

    test "returns false when patient isn't connected with specialist (via_timeline false)" do
      specialist = Authentication.Factory.insert(:verified_specialist)
      patient = PatientProfile.Factory.insert(:patient)

      refute SpecialistPatientConnection.specialist_patient_connected?(
               specialist.id,
               patient.id,
               false
             )
    end

    test "returns true when patient is connected with specialist (via_timeline true)" do
      specialist = Authentication.Factory.insert(:verified_specialist)
      patient = PatientProfile.Factory.insert(:patient)

      timeline = EMR.Factory.insert(:automatic_record, patient_id: patient.id)
      SpecialistPatientConnection.create(specialist.id, patient.id)

      assert SpecialistPatientConnection.specialist_patient_connected?(
               specialist.id,
               timeline.id,
               true
             )
    end

    test "returns false when patient isn't connected with specialist (via_timeline true)" do
      specialist = Authentication.Factory.insert(:verified_specialist)
      patient = PatientProfile.Factory.insert(:patient)

      timeline = EMR.Factory.insert(:automatic_record, patient_id: patient.id)

      refute SpecialistPatientConnection.specialist_patient_connected?(
               specialist.id,
               timeline.id,
               true
             )
    end
  end

  test "fetch_patient_specialists_ids/1 returns the list of doctors who connected with the patient" do
    patient = PatientProfile.Factory.insert(:patient)

    connected_specialist = Authentication.Factory.insert(:verified_specialist)
    _other_specialist = Authentication.Factory.insert(:verified_specialist)

    SpecialistPatientConnection.create(connected_specialist.id, patient.id)

    assert {:ok, [found_specialist_id]} = EMR.fetch_patient_specialists_ids(patient.id)
    assert found_specialist_id == connected_specialist.id
  end
end
