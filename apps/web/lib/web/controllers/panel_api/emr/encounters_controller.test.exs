defmodule Web.PanelApi.EMR.EncountersControllerTest do
  use Web.ConnCase, async: true

  alias Proto.EMR.SpecialistEncounterResponse
  alias Proto.EMR.SpecialistEncountersResponse
  alias Proto.EMR.SpecialistEncountersStatsResponse

  describe "GET index" do
    setup [:authenticate_external]

    test "return current specialist's results if no specialist_id in params", %{
      conn: conn,
      current_external: current_external
    } do
      patient = insert_patient()
      specialist_2 = Authentication.Factory.insert(:verified_and_approved_external)

      record_current_external =
        EMR.Factory.insert(:active_record,
          patient_id: patient.id,
          specialist_id: current_external.id
        )

      _record_specialist_2 =
        EMR.Factory.insert(:active_record,
          patient_id: patient.id,
          specialist_id: specialist_2.id
        )

      conn = get(conn, panel_emr_encounters_path(conn, :index))

      assert %SpecialistEncountersResponse{
               encounters: [
                 %{
                   id: result_record_id,
                   state: result_state,
                   type: result_type,
                   us_board_request_id: ""
                 }
               ],
               patients: [_],
               next_token: _
             } = proto_response(conn, 200, SpecialistEncountersResponse)

      assert result_state == :PENDING
      assert result_type == :VISIT
      assert result_record_id == record_current_external.id
    end

    test "return current specialist's result for US board visit", %{
      conn: conn,
      current_external: current_external
    } do
      patient = insert_patient()

      {:ok, %{id: request_id}} =
        insert_us_board_request(patient.id)

      record_current_external =
        EMR.Factory.insert(:active_record,
          patient_id: patient.id,
          specialist_id: current_external.id,
          us_board_request_id: request_id
        )

      conn = get(conn, panel_emr_encounters_path(conn, :index))

      assert %SpecialistEncountersResponse{
               encounters: [
                 %{
                   id: result_record_id,
                   state: result_state,
                   type: result_type,
                   us_board_request_id: ^request_id
                 }
               ],
               patients: [_],
               next_token: _
             } = proto_response(conn, 200, SpecialistEncountersResponse)

      assert result_state == :PENDING
      assert result_type == :VISIT
      assert result_record_id == record_current_external.id
    end

    test """
         return other team member's results if:
         - specialist_id in params
         - specialist_id belongs to the same team as current specialist
         """,
         %{
           conn: conn,
           current_external: current_external
         } do
      specialist_2 = Authentication.Factory.insert(:verified_and_approved_external)
      patient = insert_patient()

      _record_current_external =
        EMR.Factory.insert(:active_record,
          patient_id: patient.id,
          specialist_id: current_external.id
        )

      record_specialist_2 =
        EMR.Factory.insert(:active_record,
          patient_id: patient.id,
          specialist_id: specialist_2.id
        )

      {:ok, %{id: team_id}} = Teams.create_team(random_id(), %{})
      :ok = add_to_team(team_id: team_id, specialist_id: specialist_2.id)
      :ok = add_to_team(team_id: team_id, specialist_id: current_external.id)

      conn =
        get(conn, panel_emr_encounters_path(conn, :index), %{
          "specialist_id" => specialist_2.id
        })

      assert %SpecialistEncountersResponse{
               encounters: [
                 %{
                   id: result_record_id
                 }
               ],
               patients: [_],
               next_token: _
             } = proto_response(conn, 200, SpecialistEncountersResponse)

      assert result_record_id == record_specialist_2.id
    end

    test """
         return 401 if:
         - specialist_id in params
         - specialist_id doesn't belong to current specialist's team
         """,
         %{
           conn: conn,
           current_external: current_external
         } do
      specialist_2 = Authentication.Factory.insert(:verified_and_approved_external)
      patient = insert_patient()

      _record_current_external =
        EMR.Factory.insert(:active_record,
          patient_id: patient.id,
          specialist_id: current_external.id
        )

      _record_specialist_2 =
        EMR.Factory.insert(:active_record,
          patient_id: patient.id,
          specialist_id: specialist_2.id
        )

      {:ok, %{id: team_id}} = Teams.create_team(random_id(), %{})
      :ok = add_to_team(team_id: team_id, specialist_id: specialist_2.id)

      conn =
        get(conn, panel_emr_encounters_path(conn, :index), %{
          "specialist_id" => specialist_2.id
        })

      assert response(conn, 401)
    end
  end

  describe "GET show" do
    setup [:authenticate_external]

    test "return encounter by id", %{
      conn: conn,
      current_external: current_external
    } do
      patient = insert_patient()

      record_current_external =
        EMR.Factory.insert(:active_record,
          patient_id: patient.id,
          specialist_id: current_external.id
        )

      conn = get(conn, panel_emr_encounters_path(conn, :show, record_current_external.id))

      assert %SpecialistEncounterResponse{
               encounter: %{
                 id: result_record_id
               },
               patient: %{
                 id: result_patient_id
               }
             } = proto_response(conn, 200, SpecialistEncounterResponse)

      assert result_record_id == record_current_external.id
      assert result_patient_id == patient.id
    end

    test "return encounter by id for US board visit", %{
      conn: conn,
      current_external: current_external
    } do
      patient = insert_patient()

      {:ok, %{id: request_id}} =
        insert_us_board_request(patient.id)

      record_current_external =
        EMR.Factory.insert(:active_record,
          patient_id: patient.id,
          specialist_id: current_external.id,
          us_board_request_id: request_id
        )

      conn = get(conn, panel_emr_encounters_path(conn, :show, record_current_external.id))

      assert %SpecialistEncounterResponse{
               encounter: %{
                 id: result_record_id,
                 us_board_request_id: ^request_id
               },
               patient: %{
                 id: result_patient_id
               }
             } = proto_response(conn, 200, SpecialistEncounterResponse)

      assert result_record_id == record_current_external.id
      assert result_patient_id == patient.id
    end
  end

  describe "GET stats" do
    setup [:authenticate_external]

    test "succeeds", %{conn: conn, current_external: current_external} do
      patient = insert_patient()

      _record =
        EMR.Factory.insert(:active_record,
          patient_id: patient.id,
          specialist_id: current_external.id,
          type: :VISIT
        )

      conn = get(conn, panel_emr_encounters_path(conn, :stats))

      assert %SpecialistEncountersStatsResponse{
               scheduled: 1,
               pending: 1,
               completed: 0,
               canceled: 0
             } = proto_response(conn, 200, SpecialistEncountersStatsResponse)
    end
  end

  defp insert_patient do
    patient = PatientProfile.Factory.insert(:patient)
    _patient_basic_info = PatientProfile.Factory.insert(:basic_info, patient_id: patient.id)
    patient
  end

  defp add_to_team(opts) do
    :ok = Teams.add_to_team(opts)
    Teams.accept_invitation(opts)
  end

  defp insert_us_board_request(patient_id) do
    %{
      patient_id: patient_id,
      status: :opinion_submitted,
      specialist_opinion: "Get better"
    }
    |> Visits.Factory.second_opinion_request_default_params()
    |> Visits.request_us_board_second_opinion()
  end

  defp random_id, do: :rand.uniform(1000)
end
