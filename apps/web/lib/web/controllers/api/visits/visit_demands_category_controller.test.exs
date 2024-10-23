defmodule Web.Api.Visits.VisitDemandsCategoryControllerTest do
  use Web.ConnCase, async: true

  import Mockery.Assertions

  alias Proto.Visits.GetVisitDemandAvailabilityResponse

  describe "POST create" do
    setup [:authenticate_patient, :proto_content]

    setup do
      specialist = Authentication.Factory.insert(:verified_and_approved_external)
      medical_category = SpecialistProfile.Factory.insert(:medical_category)

      SpecialistProfile.Specialist.update_categories([medical_category.id], specialist.id)

      %{
        specialist: specialist,
        medical_category: medical_category
      }
    end

    test "creates visit demand record for patient and category", %{
      conn: conn,
      current_patient: current_patient,
      medical_category: medical_category
    } do
      patient_id = current_patient.id
      medical_category_id = medical_category.id

      {:ok, []} = Visits.Demands.fetch_visit_demands_for_categories([medical_category_id])

      conn = post(conn, visits_visit_demands_category_path(conn, :create, medical_category_id))

      assert {:ok, [%{patient_id: ^patient_id, medical_category_id: ^medical_category_id}]} =
               Visits.Demands.fetch_visit_demands_for_categories([medical_category_id])

      assert conn.status == 201
    end

    test "sends notification to specialist if free timeslot was before current time", %{
      conn: conn,
      current_patient: current_patient,
      medical_category: medical_category,
      specialist: specialist
    } do
      patient_id = current_patient.id
      medical_category_id = medical_category.id
      specialist_id = specialist.id

      # Setup slots for specialists
      date = Timex.now()
      date_taken = Timex.shift(date, minutes: -1)

      {:ok, _day_schedule} =
        Visits.DaySchedule.insert_or_update(
          %Visits.DaySchedule{specialist_id: specialist_id, date: date},
          [%{start_time: Timex.to_unix(date_taken), visit_type: :ONLINE}],
          []
        )

      {:ok, []} = Visits.Demands.fetch_visit_demands_for_categories([medical_category_id])

      conn = post(conn, visits_visit_demands_category_path(conn, :create, medical_category_id))

      assert_called(
        PushNotifications.Message,
        :send,
        [
          %PushNotifications.Message.VisitDemandRequested{
            send_to_specialist_ids: [^specialist_id]
          }
        ]
      )

      assert {:ok, [%{patient_id: ^patient_id, medical_category_id: ^medical_category_id}]} =
               Visits.Demands.fetch_visit_demands_for_categories([medical_category_id])

      assert conn.status == 201
    end
  end

  describe "GET show" do
    setup [:authenticate_patient, :proto_content]

    setup do
      %{
        specialist: Authentication.Factory.insert(:verified_and_approved_external),
        medical_category: SpecialistProfile.Factory.insert(:medical_category)
      }
    end

    test "(no free slots) returns true when there are specialists to notify", %{
      conn: conn,
      specialist: specialist,
      medical_category: medical_category
    } do
      # Setup specialist medical category
      SpecialistProfile.Specialist.update_categories([medical_category.id], specialist.id)

      conn = get(conn, visits_visit_demands_category_path(conn, :show, medical_category.id))

      assert %GetVisitDemandAvailabilityResponse{is_visit_demand_available: true} =
               proto_response(conn, 200, GetVisitDemandAvailabilityResponse)
    end

    test "(no free slots) returns false when there are no specialsits to notify", %{
      conn: conn,
      specialist: specialist,
      medical_category: medical_category
    } do
      # Setup specialist medical category
      SpecialistProfile.Specialist.update_categories([medical_category.id], specialist.id)

      # Setup slots for specialists
      date = ~D[2100-11-15]

      {:ok, _day_schedule} =
        Visits.DaySchedule.insert_or_update(
          %Visits.DaySchedule{specialist_id: specialist.id, date: date},
          [%{start_time: Timex.to_unix(date), visit_type: :ONLINE}],
          []
        )

      # Takes one of the visits
      Visits.Commands.TakeTimeslot.call(%Visits.Commands.TakeTimeslot{
        chosen_medical_category_id: medical_category.id,
        patient_id: 1,
        specialist_id: specialist.id,
        start_time: Timex.to_unix(date),
        visit_type: :ONLINE
      })

      conn = get(conn, visits_visit_demands_category_path(conn, :show, medical_category.id))

      assert %GetVisitDemandAvailabilityResponse{is_visit_demand_available: false} =
               proto_response(conn, 200, GetVisitDemandAvailabilityResponse)
    end

    test "(free slots) returns false when there are free slots", %{
      conn: conn,
      specialist: specialist,
      medical_category: medical_category
    } do
      # Setup specialist medical category
      SpecialistProfile.Specialist.update_categories([medical_category.id], specialist.id)

      # Setup slots for specialists
      date = ~D[2100-11-15]

      {:ok, _day_schedule} =
        Visits.DaySchedule.insert_or_update(
          %Visits.DaySchedule{specialist_id: specialist.id, date: date},
          [%{start_time: Timex.to_unix(date), visit_type: :ONLINE}],
          []
        )

      conn = get(conn, visits_visit_demands_category_path(conn, :show, medical_category.id))

      assert %GetVisitDemandAvailabilityResponse{is_visit_demand_available: false} =
               proto_response(conn, 200, GetVisitDemandAvailabilityResponse)
    end

    test "(free slots) returns true if visit was today", %{
      conn: conn,
      specialist: specialist,
      medical_category: medical_category
    } do
      # Setup specialist medical category
      SpecialistProfile.Specialist.update_categories([medical_category.id], specialist.id)

      # Setup slots for specialists
      date = Timex.now()
      date_taken = Timex.shift(date, minutes: -1)

      {:ok, _day_schedule} =
        Visits.DaySchedule.insert_or_update(
          %Visits.DaySchedule{specialist_id: specialist.id, date: date},
          [],
          [
            %{
              id: UUID.uuid4(),
              start_time: Timex.to_unix(date_taken),
              patient_id: 1,
              record_id: 1,
              visit_id: "1",
              visit_type: :ONLINE
            }
          ]
        )

      conn = get(conn, visits_visit_demands_category_path(conn, :show, medical_category.id))

      assert %GetVisitDemandAvailabilityResponse{is_visit_demand_available: true} =
               proto_response(conn, 200, GetVisitDemandAvailabilityResponse)
    end

    test "(no free slots) returns false is specialist has taken schedule tomorrow or later", %{
      conn: conn,
      specialist: specialist,
      medical_category: medical_category
    } do
      # Setup specialist medical category
      SpecialistProfile.Specialist.update_categories([medical_category.id], specialist.id)

      # Setup slots for specialists
      date = Timex.now()
      date_taken = Timex.shift(date, minutes: -1)

      {:ok, _day_schedule} =
        Visits.DaySchedule.insert_or_update(
          %Visits.DaySchedule{specialist_id: specialist.id, date: date},
          [],
          [
            %{
              id: UUID.uuid4(),
              start_time: Timex.to_unix(date_taken),
              patient_id: 1,
              record_id: 1,
              visit_id: "1",
              visit_type: :ONLINE
            }
          ]
        )

      two_days_later = Timex.shift(date, days: 2)
      two_days_later_date_taken = Timex.shift(two_days_later, minutes: -1)

      {:ok, _day_schedule} =
        Visits.DaySchedule.insert_or_update(
          %Visits.DaySchedule{specialist_id: specialist.id, date: two_days_later},
          [],
          [
            %{
              id: UUID.uuid4(),
              start_time: Timex.to_unix(two_days_later_date_taken),
              patient_id: 2,
              record_id: 2,
              visit_id: "2",
              visit_type: :ONLINE
            }
          ]
        )

      conn = get(conn, visits_visit_demands_category_path(conn, :show, medical_category.id))

      assert %GetVisitDemandAvailabilityResponse{is_visit_demand_available: false} =
               proto_response(conn, 200, GetVisitDemandAvailabilityResponse)
    end

    test "(no free slots) returns false is specialist has free schedule tomorrow or later", %{
      conn: conn,
      specialist: specialist,
      medical_category: medical_category
    } do
      # Setup specialist medical category
      SpecialistProfile.Specialist.update_categories([medical_category.id], specialist.id)

      # Setup slots for specialists
      date = Timex.now()
      date_taken = Timex.shift(date, minutes: -1)

      {:ok, _day_schedule} =
        Visits.DaySchedule.insert_or_update(
          %Visits.DaySchedule{specialist_id: specialist.id, date: date},
          [],
          [
            %{
              id: UUID.uuid4(),
              start_time: Timex.to_unix(date_taken),
              patient_id: 1,
              record_id: 1,
              visit_id: "1",
              visit_type: :ONLINE
            }
          ]
        )

      two_days_later = Timex.shift(date, days: 2)

      {:ok, _day_schedule} =
        Visits.DaySchedule.insert_or_update(
          %Visits.DaySchedule{specialist_id: specialist.id, date: two_days_later},
          [%{start_time: Timex.to_unix(two_days_later), visit_type: :ONLINE}],
          []
        )

      conn = get(conn, visits_visit_demands_category_path(conn, :show, medical_category.id))

      assert %GetVisitDemandAvailabilityResponse{is_visit_demand_available: false} =
               proto_response(conn, 200, GetVisitDemandAvailabilityResponse)
    end
  end
end
