defmodule Web.PanelApi.Calls.VisitCallControllerTest do
  use Web.ConnCase, async: true

  alias Proto.Calls.DoctorPendingVisitCallRequest
  alias Proto.Calls.DoctorPendingVisitCallResponse
  alias Proto.Calls.PendingVisitCallRequest
  alias Proto.Calls.PendingVisitCallResponse

  describe "POST pending_visit_call by GP" do
    setup [:authenticate_gp, :proto_content, :accept_proto]

    test "returns necessary info about call", %{conn: conn} do
      patient_id = 1
      doctor_id = 1

      date = Date.utc_today()
      start_time = DateTime.utc_now() |> Timex.to_unix()

      {:ok, _day_schedule} =
        Visits.DaySchedule.insert_or_update(
          %Visits.DaySchedule{specialist_id: doctor_id, date: date},
          [%{start_time: start_time, visit_type: :ONLINE}],
          []
        )

      cmd = %Visits.Commands.TakeTimeslot{
        specialist_id: doctor_id,
        start_time: start_time,
        patient_id: patient_id,
        chosen_medical_category_id: 1,
        visit_type: :ONLINE
      }

      {:ok, visit} = Visits.take_timeslot(cmd)

      proto =
        %PendingVisitCallRequest{
          visit_id: visit.id
        }
        |> PendingVisitCallRequest.encode()

      conn = post(conn, panel_calls_visit_call_path(conn, :pending_visit_call), proto)

      assert %PendingVisitCallResponse{
               api_key: _,
               call_id: _,
               gp_session_token: _,
               patient_id: fetched_patient_id,
               session_id: _
             } = proto_response(conn, 200, PendingVisitCallResponse)

      assert fetched_patient_id == patient_id
    end
  end

  describe "POST doctor_pending_visit_call by Doctor" do
    setup [:authenticate_external, :proto_content, :accept_proto]

    defp create_pending_visit(start_time, date, doctor, patient_id, visit_type) do
      {:ok, _day_schedule} =
        Visits.DaySchedule.insert_or_update(
          %Visits.DaySchedule{specialist_id: doctor.id, date: date},
          [%{start_time: start_time, visit_type: visit_type}],
          []
        )

      cmd = %Visits.Commands.TakeTimeslot{
        specialist_id: doctor.id,
        start_time: start_time,
        patient_id: patient_id,
        chosen_medical_category_id: 1,
        visit_type: visit_type
      }

      Visits.take_timeslot(cmd)
    end

    test "returns necessary info about call", %{conn: conn, current_external: doctor} do
      patient_id = 1

      date = Date.utc_today()
      start_time = DateTime.utc_now() |> Timex.to_unix()

      {:ok, pending_visit} = create_pending_visit(start_time, date, doctor, patient_id, :ONLINE)

      proto =
        %DoctorPendingVisitCallRequest{
          visit_id: pending_visit.id
        }
        |> DoctorPendingVisitCallRequest.encode()

      conn = post(conn, panel_calls_visit_call_path(conn, :doctor_pending_visit_call), proto)

      assert %DoctorPendingVisitCallResponse{
               api_key: _,
               call_id: _,
               doctor_session_token: _,
               patient_id: fetched_patient_id,
               session_id: _
             } = proto_response(conn, 200, DoctorPendingVisitCallResponse)

      assert fetched_patient_id == patient_id
    end

    test "returns proper error when call is made after timeslot", %{
      conn: conn,
      current_external: doctor
    } do
      patient_id = 1

      date = Date.utc_today()

      start_time =
        NaiveDateTime.utc_now() |> Timex.shift(hours: -1) |> Timex.to_unix()

      {:ok, pending_visit} = create_pending_visit(start_time, date, doctor, patient_id, :ONLINE)

      proto =
        %DoctorPendingVisitCallRequest{
          visit_id: pending_visit.id
        }
        |> DoctorPendingVisitCallRequest.encode()

      conn = post(conn, panel_calls_visit_call_path(conn, :doctor_pending_visit_call), proto)

      assert %Proto.Errors.ErrorResponse{
               simple_error: %Proto.Errors.SimpleError{message: error_message}
             } = proto_response(conn, 422, Proto.Errors.ErrorResponse)

      assert error_message == "Time to make a call has already passed"
    end

    test "returns proper error when call is made before timeslot", %{
      conn: conn,
      current_external: doctor
    } do
      patient_id = 1

      date = Date.utc_today()
      start_time = NaiveDateTime.utc_now() |> Timex.shift(hours: 1) |> Timex.to_unix()

      {:ok, pending_visit} = create_pending_visit(start_time, date, doctor, patient_id, :ONLINE)

      proto =
        %DoctorPendingVisitCallRequest{
          visit_id: pending_visit.id
        }
        |> DoctorPendingVisitCallRequest.encode()

      conn = post(conn, panel_calls_visit_call_path(conn, :doctor_pending_visit_call), proto)

      assert %Proto.Errors.ErrorResponse{
               simple_error: %Proto.Errors.SimpleError{message: error_message}
             } = proto_response(conn, 422, Proto.Errors.ErrorResponse)

      assert error_message == "You have to wait for scheduled time to make a call"
    end

    test "returns proper error when in office visit is made after timeslot", %{
      conn: conn,
      current_external: doctor
    } do
      patient_id = 1

      date = Date.utc_today()

      start_time =
        NaiveDateTime.utc_now() |> Timex.shift(hours: -1) |> Timex.to_unix()

      {:ok, pending_visit} =
        create_pending_visit(start_time, date, doctor, patient_id, :IN_OFFICE)

      proto =
        %DoctorPendingVisitCallRequest{
          visit_id: pending_visit.id
        }
        |> DoctorPendingVisitCallRequest.encode()

      conn = post(conn, panel_calls_visit_call_path(conn, :doctor_pending_visit_call), proto)

      assert %Proto.Errors.ErrorResponse{
               simple_error: %Proto.Errors.SimpleError{message: error_message}
             } = proto_response(conn, 422, Proto.Errors.ErrorResponse)

      assert error_message == "Time to start a visit has already passed"
    end

    test "returns proper error when in office visit is started before timeslot", %{
      conn: conn,
      current_external: doctor
    } do
      patient_id = 1

      date = Date.utc_today()
      start_time = NaiveDateTime.utc_now() |> Timex.shift(hours: 1) |> Timex.to_unix()

      {:ok, pending_visit} =
        create_pending_visit(start_time, date, doctor, patient_id, :IN_OFFICE)

      proto =
        %DoctorPendingVisitCallRequest{
          visit_id: pending_visit.id
        }
        |> DoctorPendingVisitCallRequest.encode()

      conn = post(conn, panel_calls_visit_call_path(conn, :doctor_pending_visit_call), proto)

      assert %Proto.Errors.ErrorResponse{
               simple_error: %Proto.Errors.SimpleError{message: error_message}
             } = proto_response(conn, 422, Proto.Errors.ErrorResponse)

      assert error_message == "You have to wait for scheduled time to start a visit"
    end
  end
end
