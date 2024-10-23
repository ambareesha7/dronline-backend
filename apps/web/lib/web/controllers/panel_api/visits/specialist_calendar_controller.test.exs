defmodule Web.PanelApi.Visits.SpecialistCalendarControllerTest do
  use Web.ConnCase, async: false

  alias Proto.Visits.CreateTimeslotsRequest
  alias Proto.Visits.GetCalendarResponse
  alias Proto.Visits.RemoveTimeslotsRequest
  alias Proto.Visits.TimeslotParams

  describe "POST create_timeslots" do
    setup [:authenticate_external, :proto_content]

    test "successfully create timeslots", %{conn: conn} do
      timeslot_to_insert_1 = %TimeslotParams{
        start_time: Timex.to_unix(~N[2030-11-30T12:00:00]),
        visit_type: :ONLINE
      }

      timeslot_to_insert_2 = %TimeslotParams{
        start_time: Timex.to_unix(~N[2030-11-30T12:15:00]),
        visit_type: :IN_OFFICE
      }

      timeslot_to_insert_3 = %TimeslotParams{
        start_time: Timex.to_unix(~N[2030-11-30T12:30:00]),
        visit_type: :BOTH
      }

      proto =
        %{timeslot_params: [timeslot_to_insert_1, timeslot_to_insert_2, timeslot_to_insert_3]}
        |> CreateTimeslotsRequest.new()
        |> CreateTimeslotsRequest.encode()

      day_schedules = Postgres.Repo.all(Visits.DaySchedule)
      assert Enum.empty?(day_schedules)

      conn = post(conn, panel_visits_specialist_calendar_path(conn, :create_timeslots), proto)

      assert response(conn, 201)

      updated_day_schedules = Postgres.Repo.all(Visits.DaySchedule)
      assert length(updated_day_schedules) == 1

      free_timeslots = Enum.at(updated_day_schedules, 0).free_timeslots

      assert Enum.find(free_timeslots, &(&1.start_time == timeslot_to_insert_1.start_time))
      assert Enum.find(free_timeslots, &(&1.start_time == timeslot_to_insert_2.start_time))
      assert Enum.find(free_timeslots, &(&1.start_time == timeslot_to_insert_3.start_time))
    end

    test "successfully updates timeslots", %{conn: conn} do
      date_1 = Timex.to_unix(~N[2030-11-30T12:00:00])
      date_2 = Timex.to_unix(~N[2030-11-30T12:15:00])

      timeslot_to_insert_1 = %TimeslotParams{
        start_time: date_1,
        visit_type: :ONLINE
      }

      timeslot_to_insert_2 = %TimeslotParams{
        start_time: date_1,
        visit_type: :IN_OFFICE
      }

      timeslot_to_insert_3 = %TimeslotParams{
        start_time: date_2,
        visit_type: :BOTH
      }

      proto_1 =
        %{timeslot_params: [timeslot_to_insert_1]}
        |> CreateTimeslotsRequest.new()
        |> CreateTimeslotsRequest.encode()

      post(conn, panel_visits_specialist_calendar_path(conn, :create_timeslots), proto_1)
      day_schedule = Postgres.Repo.one(Visits.DaySchedule)

      assert length(day_schedule.free_timeslots) == 1

      proto_2 =
        %{timeslot_params: [timeslot_to_insert_2, timeslot_to_insert_3]}
        |> CreateTimeslotsRequest.new()
        |> CreateTimeslotsRequest.encode()

      post(conn, panel_visits_specialist_calendar_path(conn, :create_timeslots), proto_2)
      day_schedule = Postgres.Repo.one(Visits.DaySchedule)

      assert length(day_schedule.free_timeslots) == 2

      assert Enum.find(
               day_schedule.free_timeslots,
               &(&1.start_time == date_1 && &1.visit_type == :IN_OFFICE)
             )

      assert Enum.find(
               day_schedule.free_timeslots,
               &(&1.start_time == date_2 && &1.visit_type == :BOTH)
             )
    end
  end

  describe "DELETE remove_timeslots" do
    setup [:authenticate_external, :proto_content]

    test "returns 200 on success", %{conn: conn} do
      proto =
        %{
          timeslot_params: [
            %TimeslotParams{
              start_time: Timex.to_unix(~N[2100-11-15T11:30:00])
            }
          ]
        }
        |> RemoveTimeslotsRequest.new()
        |> RemoveTimeslotsRequest.encode()

      conn = delete(conn, panel_visits_specialist_calendar_path(conn, :remove_timeslots), proto)

      assert response(conn, 200)
    end
  end

  describe "GET my_calendar" do
    setup [:authenticate_external]

    test "returns all timeslots of current external freelancer", %{
      conn: conn,
      current_external: current_external
    } do
      date = ~D[2100-11-15]
      start_time1 = ~N[2100-11-15T12:00:00] |> Timex.to_unix()
      start_time2 = ~N[2100-11-15T12:30:00] |> Timex.to_unix()
      visit_id = UUID.uuid4()

      {:ok, _day_schedule} =
        Visits.DaySchedule.insert_or_update(
          %Visits.DaySchedule{specialist_id: current_external.id, date: date},
          [%{start_time: start_time1, visit_type: :IN_OFFICE}],
          [
            %{
              id: UUID.uuid4(),
              start_time: start_time2,
              patient_id: 1,
              record_id: 1,
              visit_id: visit_id,
              visit_type: :ONLINE
            }
          ]
        )

      params = %{"month" => date |> Timex.to_unix() |> to_string()}
      conn = get(conn, panel_visits_specialist_calendar_path(conn, :my_calendar), params)

      assert %GetCalendarResponse{timeslots: [timeslot1, timeslot2]} =
               proto_response(conn, 200, GetCalendarResponse)

      assert timeslot1 == %Proto.Visits.Timeslot{
               start_time: start_time1,
               status: {:free, %Proto.Visits.Timeslot.Free{visit_type: :IN_OFFICE}}
             }

      assert timeslot2 == %Proto.Visits.Timeslot{
               start_time: start_time2,
               status:
                 {:taken,
                  %Proto.Visits.Timeslot.Taken{
                    patient_id: 1,
                    record_id: 1,
                    visit_state: :UNKNOWN,
                    visit_id: visit_id,
                    visit_type: :ONLINE
                  }}
             }
    end

    test "can return the calendar of team member", %{
      conn: conn,
      current_external: current_external
    } do
      date = ~D[2100-11-15]
      start_time = ~N[2100-11-15T12:00:00] |> Timex.to_unix()

      {:ok, %{id: team_id}} = Teams.create_team(current_external.id, %{})
      specialist = Authentication.Factory.insert(:verified_and_approved_external)
      :ok = add_to_team(team_id: team_id, specialist_id: specialist.id)

      {:ok, _day_schedule} =
        Visits.DaySchedule.insert_or_update(
          %Visits.DaySchedule{specialist_id: specialist.id, date: date},
          [%{start_time: start_time, visit_type: :IN_OFFICE}],
          []
        )

      params = %{
        "month" => date |> Timex.to_unix() |> to_string(),
        "specialist_id" => specialist.id
      }

      resp = get(conn, panel_visits_specialist_calendar_path(conn, :my_calendar), params)

      assert %GetCalendarResponse{timeslots: [_timeslot]} =
               proto_response(resp, 200, GetCalendarResponse)
    end

    test "cannot see availability of people outside the team", %{
      conn: conn
    } do
      date = ~D[2100-11-15]
      start_time = ~N[2100-11-15T12:00:00] |> Timex.to_unix()

      specialist = Authentication.Factory.insert(:verified_and_approved_external)

      {:ok, _day_schedule} =
        Visits.DaySchedule.insert_or_update(
          %Visits.DaySchedule{specialist_id: specialist.id, date: date},
          [%{start_time: start_time, visit_type: :ONLINE}],
          []
        )

      params = %{
        "month" => date |> Timex.to_unix() |> to_string(),
        "specialist_id" => specialist.id
      }

      conn = get(conn, panel_visits_specialist_calendar_path(conn, :my_calendar), params)

      assert response(conn, 401)
    end
  end

  defp add_to_team(opts) do
    :ok = Teams.add_to_team(opts)
    Teams.accept_invitation(opts)
  end
end
