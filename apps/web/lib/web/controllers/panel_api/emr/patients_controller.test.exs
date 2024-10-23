defmodule Web.PanelApi.EMR.PatientsControllerTest do
  use Web.ConnCase, async: true

  alias Proto.EMR.CreatePatientRequest
  alias Proto.EMR.CreatePatientResponse
  alias Proto.EMR.GetPatientsResponse

  describe "POST create" do
    setup [:authenticate_nurse, :proto_content]

    test "succeeds when patient doesn't exists", %{conn: conn} do
      firebase_token = Firebase.TestHelper.firebase_auth_token("3000-01-01")

      proto =
        %{
          firebase_token: firebase_token
        }
        |> Proto.validate!(CreatePatientRequest)
        |> CreatePatientRequest.new()
        |> CreatePatientRequest.encode()

      conn = post(conn, panel_emr_patients_path(conn, :create), proto)

      assert %CreatePatientResponse{patient_id: patient_id} =
               proto_response(conn, 200, CreatePatientResponse)

      assert is_integer(patient_id)
    end

    test "succeeds when patient exists", %{conn: conn} do
      firebase_token = Firebase.TestHelper.firebase_auth_token("3000-01-01", "firebase_id")

      patient = PatientProfile.Factory.insert(:patient)
      {:ok, _auth_token} = Authentication.Patient.AuthTokenEntry.create(patient.id)

      {:ok, _account} =
        Authentication.Patient.Account.create(%{
          firebase_id: "firebase_id",
          main_patient_id: patient.id,
          phone_number: "+48661848585"
        })

      proto =
        %{
          firebase_token: firebase_token
        }
        |> Proto.validate!(CreatePatientRequest)
        |> CreatePatientRequest.new()
        |> CreatePatientRequest.encode()

      conn = post(conn, panel_emr_patients_path(conn, :create), proto)

      assert %CreatePatientResponse{patient_id: patient_id} =
               proto_response(conn, 200, CreatePatientResponse)

      assert patient_id == patient.id
    end
  end

  describe "GET index" do
    setup [:authenticate_nurse]

    test "succeeds", %{conn: conn, current_nurse: nurse} do
      patient1 = PatientProfile.Factory.insert(:patient)
      basic_info1 = PatientProfile.Factory.insert(:basic_info, patient_id: patient1.id)
      _address1 = PatientProfile.Factory.insert(:address, patient_id: patient1.id)

      patient2 = PatientProfile.Factory.insert(:patient)
      _basic_info2 = PatientProfile.Factory.insert(:basic_info, patient_id: patient2.id)
      _address2 = PatientProfile.Factory.insert(:address, patient_id: patient2.id)

      EMR.SpecialistPatientConnections.SpecialistPatientConnection.create(
        nurse.id,
        patient1.id
      )

      EMR.SpecialistPatientConnections.SpecialistPatientConnection.create(
        nurse.id,
        patient2.id
      )

      conn = get(conn, panel_emr_patients_path(conn, :index), limit: "1")

      expected_next_token = patient2.id |> to_string()

      %GetPatientsResponse{patients: [patient], next_token: ^expected_next_token} =
        proto_response(conn, 200, GetPatientsResponse)

      assert patient.first_name == basic_info1.first_name
    end
  end

  describe "GET index_connected" do
    setup [:authenticate_external_platinum]

    test "succeeds", %{conn: conn, current_external: current_external} do
      patient = PatientProfile.Factory.insert(:patient)
      basic_info = PatientProfile.Factory.insert(:basic_info, patient_id: patient.id)
      _address = PatientProfile.Factory.insert(:address, patient_id: patient.id)

      EMR.register_interaction_between(current_external.id, patient.id)

      conn = get(conn, panel_emr_patients_path(conn, :index_connected))

      %GetPatientsResponse{patients: [patient], next_token: ""} =
        proto_response(conn, 200, GetPatientsResponse)

      assert patient.first_name == basic_info.first_name
    end
  end

  describe "GET index_connected_to_team_member" do
    setup [:authenticate_gp]

    test "succeedes when Specialist belongs to team", %{conn: conn, current_gp: current_gp} do
      patient = PatientProfile.Factory.insert(:patient)
      basic_info = PatientProfile.Factory.insert(:basic_info, patient_id: patient.id)
      _address = PatientProfile.Factory.insert(:address, patient_id: patient.id)

      owner_id = 1
      {:ok, %{id: team_id}} = Teams.create_team(owner_id, %{})

      :ok = add_to_team(team_id: team_id, specialist_id: current_gp.id)
      :ok = Teams.set_admin_role(owner_id, current_gp.id)

      team_member = Authentication.Factory.insert(:specialist)
      :ok = add_to_team(team_id: team_id, specialist_id: team_member.id)

      EMR.register_interaction_between(team_member.id, patient.id)

      conn =
        get(conn, panel_emr_patients_path(conn, :index_connected_to_team_member, team_member.id))

      %GetPatientsResponse{patients: [patient], next_token: ""} =
        proto_response(conn, 200, GetPatientsResponse)

      assert patient.first_name == basic_info.first_name
    end

    test "401 when Specialist doesn't belong to team", %{conn: conn, current_gp: current_gp} do
      patient = PatientProfile.Factory.insert(:patient)

      owner_id = 1
      {:ok, %{id: team_id}} = Teams.create_team(owner_id, %{})

      :ok = add_to_team(team_id: team_id, specialist_id: current_gp.id)
      :ok = Teams.set_admin_role(owner_id, current_gp.id)

      not_a_team_member = Authentication.Factory.insert(:specialist)
      EMR.register_interaction_between(not_a_team_member.id, patient.id)

      conn =
        get(
          conn,
          panel_emr_patients_path(conn, :index_connected_to_team_member, not_a_team_member.id)
        )

      assert response(conn, 401)
    end
  end

  defp add_to_team(opts) do
    :ok = Teams.add_to_team(opts)
    Teams.accept_invitation(opts)
  end
end
