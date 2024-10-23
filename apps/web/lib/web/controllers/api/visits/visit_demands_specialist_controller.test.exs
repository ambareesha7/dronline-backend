defmodule Web.Api.Visits.VisitDemandsSpecialistControllerTest do
  use Web.ConnCase, async: true
  import Mockery.Assertions

  alias Proto.Visits.GetVisitDemandAvailabilityResponse

  describe "POST create" do
    setup [:authenticate_patient, :proto_content]

    setup do
      %{
        specialist: Authentication.Factory.insert(:verified_and_approved_external)
      }
    end

    test "creates visit demand record for patient and category", %{
      conn: conn,
      current_patient: current_patient,
      specialist: specialist
    } do
      specialist_id = specialist.id
      patient_id = current_patient.id

      {:ok, []} = Visits.Demands.fetch_visit_demands_for_specialist(specialist_id)

      conn = post(conn, visits_visit_demands_specialist_path(conn, :create, specialist_id))

      assert {:ok, [%{patient_id: ^patient_id, specialist_id: ^specialist_id}]} =
               Visits.Demands.fetch_visit_demands_for_specialist(specialist_id)

      assert conn.status == 201
    end

    test "sends notification to specialist with no taken timeslots later", %{
      conn: conn,
      current_patient: current_patient,
      specialist: specialist
    } do
      specialist_id = specialist.id
      patient_id = current_patient.id

      # Setup slots for specialists
      date = Timex.shift(Timex.now(), minutes: -1)

      {:ok, _day_schedule} =
        Visits.DaySchedule.insert_or_update(
          %Visits.DaySchedule{specialist_id: specialist_id, date: date},
          [],
          [
            %{
              id: UUID.uuid4(),
              start_time: Timex.to_unix(date),
              patient_id: patient_id,
              record_id: 2,
              visit_id: "2",
              visit_type: :ONLINE
            }
          ]
        )

      {:ok, []} = Visits.Demands.fetch_visit_demands_for_specialist(specialist_id)

      conn = post(conn, visits_visit_demands_specialist_path(conn, :create, specialist_id))

      assert_called(
        PushNotifications.Message,
        :send,
        [
          %PushNotifications.Message.VisitDemandRequested{
            send_to_specialist_ids: [^specialist_id]
          }
        ]
      )

      assert {:ok, [%{patient_id: ^patient_id, specialist_id: ^specialist_id}]} =
               Visits.Demands.fetch_visit_demands_for_specialist(specialist_id)

      assert conn.status == 201
    end

    test "sends notification to specialist with no free timeslots later", %{
      conn: conn,
      current_patient: current_patient,
      specialist: specialist
    } do
      specialist_id = specialist.id
      patient_id = current_patient.id

      # Setup slots for specialists
      date = Timex.shift(Timex.now(), minutes: -1)

      {:ok, _day_schedule} =
        Visits.DaySchedule.insert_or_update(
          %Visits.DaySchedule{specialist_id: specialist_id, date: date},
          [%{start_time: Timex.to_unix(date), visit_type: :ONLINE}],
          []
        )

      {:ok, []} = Visits.Demands.fetch_visit_demands_for_specialist(specialist_id)

      conn = post(conn, visits_visit_demands_specialist_path(conn, :create, specialist_id))

      assert_called(
        PushNotifications.Message,
        :send,
        [
          %PushNotifications.Message.VisitDemandRequested{
            send_to_specialist_ids: [^specialist_id]
          }
        ]
      )

      assert {:ok, [%{patient_id: ^patient_id, specialist_id: ^specialist_id}]} =
               Visits.Demands.fetch_visit_demands_for_specialist(specialist_id)

      assert conn.status == 201
    end

    test "doesn't send notification to specialist with taken timeslots later", %{
      conn: conn,
      specialist: specialist
    } do
      specialist_id = specialist.id

      # Setup slots for specialists
      date = Timex.shift(Timex.now(), minutes: 1)

      {:ok, _day_schedule} =
        Visits.DaySchedule.insert_or_update(
          %Visits.DaySchedule{specialist_id: specialist_id, date: date},
          [],
          [
            %{
              id: UUID.uuid4(),
              start_time: Timex.to_unix(date),
              patient_id: 2,
              record_id: 2,
              visit_id: "2",
              visit_type: :ONLINE
            }
          ]
        )

      {:ok, []} = Visits.Demands.fetch_visit_demands_for_specialist(specialist_id)

      _conn = post(conn, visits_visit_demands_specialist_path(conn, :create, specialist_id))

      refute_called(
        PushNotifications.Message,
        :send,
        [
          %PushNotifications.Message.VisitDemandRequested{
            send_to_specialist_ids: [^specialist_id]
          }
        ]
      )
    end

    test "doesn't send notification to specialist with free timeslots later", %{
      conn: conn,
      specialist: specialist
    } do
      specialist_id = specialist.id

      # Setup slots for specialists
      date = Timex.shift(Timex.now(), minutes: 1)

      {:ok, _day_schedule} =
        Visits.DaySchedule.insert_or_update(
          %Visits.DaySchedule{specialist_id: specialist_id, date: date},
          [%{start_time: Timex.to_unix(date), visit_type: :ONLINE}],
          []
        )

      {:ok, []} = Visits.Demands.fetch_visit_demands_for_specialist(specialist_id)

      _conn = post(conn, visits_visit_demands_specialist_path(conn, :create, specialist_id))

      refute_called(
        PushNotifications.Message,
        :send,
        [
          %PushNotifications.Message.VisitDemandRequested{
            send_to_specialist_ids: [^specialist_id]
          }
        ]
      )
    end
  end

  describe "GET show" do
    setup [:authenticate_patient, :proto_content]

    test "(no free slots) returns true when specialist should be notified", %{conn: conn} do
      specialist = Authentication.Factory.insert(:verified_and_approved_external)

      conn = get(conn, visits_visit_demands_specialist_path(conn, :show, specialist.id))

      assert %GetVisitDemandAvailabilityResponse{is_visit_demand_available: true} =
               proto_response(conn, 200, GetVisitDemandAvailabilityResponse)
    end

    test "(no free slots) returns false when specialist has slots but taken", %{conn: conn} do
      specialist = Authentication.Factory.insert(:verified_and_approved_external)

      # Setup slots for specialists
      date = ~D[2100-11-15]

      {:ok, _day_schedule} =
        Visits.DaySchedule.insert_or_update(
          %Visits.DaySchedule{specialist_id: specialist.id, date: date},
          [%{start_time: date |> Timex.to_unix(), visit_type: :ONLINE}],
          []
        )

      # Takes one of the visits
      Visits.Commands.TakeTimeslot.call(%Visits.Commands.TakeTimeslot{
        chosen_medical_category_id: 1,
        patient_id: 1,
        specialist_id: specialist.id,
        start_time: Timex.to_unix(date),
        visit_type: :ONLINE
      })

      conn = get(conn, visits_visit_demands_specialist_path(conn, :show, specialist.id))

      assert %GetVisitDemandAvailabilityResponse{is_visit_demand_available: false} =
               proto_response(conn, 200, GetVisitDemandAvailabilityResponse)
    end

    test "(free slots) returns false when specialist has got free slots", %{conn: conn} do
      specialist = Authentication.Factory.insert(:verified_and_approved_external)

      # Setup slots for specialists
      date = ~D[2100-11-15]

      {:ok, _day_schedule} =
        Visits.DaySchedule.insert_or_update(
          %Visits.DaySchedule{specialist_id: specialist.id, date: date},
          [%{start_time: Timex.to_unix(date), visit_type: :ONLINE}],
          []
        )

      conn = get(conn, visits_visit_demands_specialist_path(conn, :show, specialist.id))

      assert %GetVisitDemandAvailabilityResponse{is_visit_demand_available: false} =
               proto_response(conn, 200, GetVisitDemandAvailabilityResponse)
    end

    test "(free slots) returns true when specialist had a visit only today", %{conn: conn} do
      specialist = Authentication.Factory.insert(:verified_and_approved_external)

      # Setup slots for specialists
      date = Timex.now()

      {:ok, _day_schedule} =
        Visits.DaySchedule.insert_or_update(
          %Visits.DaySchedule{specialist_id: specialist.id, date: date},
          [],
          [
            %{
              id: UUID.uuid4(),
              start_time: date |> Timex.shift(minutes: -1) |> Timex.to_unix(),
              patient_id: 2,
              record_id: 2,
              visit_id: "2",
              visit_type: :ONLINE
            }
          ]
        )

      conn = get(conn, visits_visit_demands_specialist_path(conn, :show, specialist.id))

      assert %GetVisitDemandAvailabilityResponse{is_visit_demand_available: true} =
               proto_response(conn, 200, GetVisitDemandAvailabilityResponse)
    end
  end
end
