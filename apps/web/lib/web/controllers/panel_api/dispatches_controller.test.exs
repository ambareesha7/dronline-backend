defmodule Web.PanelApi.DispatchesControllerTest do
  use Web.ConnCase, async: true

  alias Proto.Dispatches.RequestDispatchToPatientRequest

  alias Proto.Dispatches.GetCurrentDispatchesResponse
  alias Proto.Dispatches.GetDispatchDetailsResponse
  alias Proto.Dispatches.GetEndedDispatchesResponse
  alias Proto.Dispatches.GetOngoingDispatchResponse
  alias Proto.Dispatches.GetPendingDispatchesResponse
  alias Proto.Dispatches.TakePendingDispatchResponse

  alias Proto.Dispatches.PatientLocation

  defp prepare_pending_dispatch do
    patient = PatientProfile.Factory.insert(:patient)
    gp = Authentication.Factory.insert(:specialist, type: "GP")
    _basic_info = PatientProfile.Factory.insert(:basic_info, patient_id: patient.id)
    _basic_info = SpecialistProfile.Factory.insert(:basic_info, specialist_id: gp.id)
    record = EMR.Factory.insert(:automatic_record, patient_id: patient.id)

    cmd = %Triage.Commands.RequestDispatchToPatient{
      patient_id: patient.id,
      patient_location_address: %{
        city: "Dubai",
        country: "United Arab Emirates",
        building_number: "1",
        postal_code: "2",
        street_name: "3",
        additional_numbers: "",
        district: ""
      },
      record_id: record.id,
      region: "united-arab-emirates-dubai",
      request_id: UUID.uuid4(),
      requester_id: gp.id
    }

    Triage.request_dispatch_to_patient(cmd)
  end

  defp prepare_ongoing_dispatch(nurse_id \\ nil) do
    nurse_id = nurse_id || Authentication.Factory.insert(:specialist, type: "NURSE").id

    {:ok, pending_dispatch} = prepare_pending_dispatch()

    cmd = %Triage.Commands.TakePendingDispatch{
      nurse_id: nurse_id,
      request_id: pending_dispatch.request_id
    }

    Triage.take_pending_dispatch(cmd)
  end

  defp prepare_ended_dispatch do
    {:ok, ongoing_dispatch} = prepare_ongoing_dispatch()

    cmd = %Triage.Commands.EndDispatch{
      nurse_id: ongoing_dispatch.nurse_id,
      request_id: ongoing_dispatch.request_id
    }

    Triage.end_dispatch(cmd)
  end

  describe "POST request_dispatch_to_patient" do
    setup [:authenticate_gp, :proto_content]

    test "dispatches command if data are correct", %{conn: conn} do
      patient = PatientProfile.Factory.insert(:patient)
      record = EMR.Factory.insert(:automatic_record, patient_id: patient.id)

      proto =
        %RequestDispatchToPatientRequest{
          patient_location: %PatientLocation{
            address: %PatientLocation.Address{
              country: "United Arab Emirates",
              city: "Dubai",
              building_number: "1",
              postal_code: "2",
              street_name: "3"
            }
          },
          patient_id: patient.id,
          record_id: record.id
        }
        |> RequestDispatchToPatientRequest.encode()

      conn = post(conn, panel_dispatches_path(conn, :request_dispatch_to_patient), proto)
      assert conn.status == 200
    end
  end

  describe "GET pending_dispatches" do
    setup [:authenticate_nurse]

    test "returns list of unassigned dispatches and associated profiles", %{conn: conn} do
      {:ok, pending_dispatch} = prepare_pending_dispatch()

      conn = get(conn, panel_dispatches_path(conn, :pending_dispatches))

      assert %GetPendingDispatchesResponse{
               dispatches: [fetched_dispatch],
               patients: [fetched_patient],
               specialists: [fetched_specialist]
             } = proto_response(conn, 200, GetPendingDispatchesResponse)

      assert fetched_dispatch.request_id == pending_dispatch.request_id

      assert Map.from_struct(fetched_dispatch.patient_location.address) ==
               Map.from_struct(pending_dispatch.patient_location_address)

      assert fetched_patient.id == pending_dispatch.patient_id
      assert fetched_specialist.id == pending_dispatch.requester_id
    end
  end

  describe "POST take_pending_dispatch" do
    setup [:authenticate_nurse, :proto_content]

    test "returns accepted dispatch and associated profiles", %{conn: conn} do
      {:ok, pending_dispatch} = prepare_pending_dispatch()

      path = panel_dispatches_path(conn, :take_pending_dispatch, pending_dispatch.request_id)
      conn = post(conn, path)

      assert %TakePendingDispatchResponse{
               dispatch: fetched_dispatch,
               patient: fetched_patient,
               specialist: fetched_specialist
             } = proto_response(conn, 200, TakePendingDispatchResponse)

      assert fetched_dispatch.request_id == pending_dispatch.request_id

      assert Map.from_struct(fetched_dispatch.patient_location.address) ==
               Map.from_struct(pending_dispatch.patient_location_address)

      assert fetched_patient.id == pending_dispatch.patient_id
      assert fetched_specialist.id == pending_dispatch.requester_id
    end
  end

  describe "GET ongoing_dispatch" do
    setup [:authenticate_nurse, :proto_content]

    test "returns ongoing dispatch and associated profiles when it exists", %{
      conn: conn,
      current_nurse: current_nurse
    } do
      {:ok, ongoing_dispatch} = prepare_ongoing_dispatch(current_nurse.id)

      conn = get(conn, panel_dispatches_path(conn, :ongoing_dispatch))

      assert %GetOngoingDispatchResponse{
               dispatch: fetched_dispatch,
               patient: fetched_patient,
               specialist: fetched_specialist
             } = proto_response(conn, 200, GetOngoingDispatchResponse)

      assert fetched_dispatch.request_id == ongoing_dispatch.request_id

      assert Map.from_struct(fetched_dispatch.patient_location.address) ==
               Map.from_struct(ongoing_dispatch.patient_location_address)

      assert fetched_patient.id == ongoing_dispatch.patient_id
      assert fetched_specialist.id == ongoing_dispatch.requester_id
    end

    test "returns empty protobuf if there's no ongoing dispatch", %{conn: conn} do
      conn = get(conn, panel_dispatches_path(conn, :ongoing_dispatch))

      assert %GetOngoingDispatchResponse{
               dispatch: nil,
               patient: nil,
               specialist: nil
             } = proto_response(conn, 200, GetOngoingDispatchResponse)
    end
  end

  describe "POST end_dispatch" do
    setup [:authenticate_nurse, :proto_content]

    test "ends dispatch", %{conn: conn, current_nurse: current_nurse} do
      {:ok, ongoing_dispatch} = prepare_ongoing_dispatch(current_nurse.id)

      conn = post(conn, panel_dispatches_path(conn, :end_dispatch, ongoing_dispatch.request_id))
      assert response(conn, 200)
    end
  end

  describe "GET current_dispatches" do
    setup [:authenticate_gp, :proto_content]

    test "returns current dispatches and associated nurses profiles", %{conn: conn} do
      {:ok, ongoing_dispatch} = prepare_ongoing_dispatch()
      {:ok, pending_dispatch} = prepare_pending_dispatch()

      _basic_info =
        SpecialistProfile.Factory.insert(:basic_info, specialist_id: ongoing_dispatch.nurse_id)

      conn = get(conn, panel_dispatches_path(conn, :current_dispatches))

      assert %GetCurrentDispatchesResponse{
               detailed_dispatches: [
                 fetched_detailed_dispatch1,
                 fetched_detailed_dispatch2
               ],
               specialists: fetched_specialists
             } = proto_response(conn, 200, GetCurrentDispatchesResponse)

      assert fetched_detailed_dispatch1.dispatch.request_id == pending_dispatch.request_id
      assert fetched_detailed_dispatch1.status == :OPEN
      assert fetched_detailed_dispatch1.nurse_id == 0

      assert fetched_detailed_dispatch2.dispatch.request_id == ongoing_dispatch.request_id
      assert fetched_detailed_dispatch2.status == :ONGOING
      assert fetched_detailed_dispatch2.nurse_id == ongoing_dispatch.nurse_id

      assert Enum.any?(fetched_specialists, &(&1.id == ongoing_dispatch.nurse_id))
    end
  end

  describe "GET ended_dispatches" do
    setup [:authenticate_gp, :proto_content]

    test "returns ended dispatches", %{conn: conn} do
      {:ok, ended_dispatch} = prepare_ended_dispatch()

      _basic_info =
        SpecialistProfile.Factory.insert(:basic_info, specialist_id: ended_dispatch.nurse_id)

      conn = get(conn, panel_dispatches_path(conn, :ended_dispatches))

      assert %GetEndedDispatchesResponse{
               detailed_dispatches: [
                 fetched_detailed_dispatch
               ],
               next_token: "",
               total_count: total_count,
               specialists: fetched_specialists
             } = proto_response(conn, 200, GetEndedDispatchesResponse)

      assert fetched_detailed_dispatch.dispatch.request_id == ended_dispatch.request_id
      assert fetched_detailed_dispatch.status == :ENDED
      assert fetched_detailed_dispatch.nurse_id == ended_dispatch.nurse_id

      assert total_count == 1
      assert Enum.any?(fetched_specialists, &(&1.id == ended_dispatch.nurse_id))
    end
  end

  describe "GET details" do
    setup [:authenticate_gp, :proto_content]

    test "returns ongoing dispatch and associated profiles when it exists", %{conn: conn} do
      {:ok, ended_dispatch} = prepare_ended_dispatch()

      conn = get(conn, panel_dispatches_path(conn, :details, ended_dispatch.request_id))

      assert %GetDispatchDetailsResponse{
               detailed_dispatch: fetched_detailed_dispatch,
               patient: fetched_patient,
               specialist: fetched_specialist
             } = proto_response(conn, 200, GetDispatchDetailsResponse)

      assert fetched_detailed_dispatch.dispatch.request_id == ended_dispatch.request_id
      assert fetched_detailed_dispatch.status == :ENDED
      assert fetched_patient.id == ended_dispatch.patient_id
      assert fetched_specialist.id == ended_dispatch.requester_id
    end
  end
end
