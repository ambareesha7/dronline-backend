defmodule Web.PanelApi.Visits.SpecialistCalendarController do
  use Conductor
  use Web, :controller

  action_fallback(Web.FallbackController)

  plug Web.Plugs.AssignQuerySpecialistId

  @authorize scopes: ["GP", "EXTERNAL"]
  @decode Proto.Visits.CreateTimeslotsRequest
  def create_timeslots(conn, _params) do
    specialist_id = conn.assigns.query_specialist_id
    timeslots_params = conn.assigns.protobuf.timeslot_params

    timeslots_details =
      Enum.map(
        timeslots_params,
        &%Visits.Commands.CreateTimeslots.TimeslotDetails{
          start_time: &1.start_time,
          visit_type: &1.visit_type
        }
      )

    cmd = %Visits.Commands.CreateTimeslots{
      specialist_id: specialist_id,
      timeslots_details: timeslots_details
    }

    with :ok <- Visits.create_timeslots(cmd) do
      conn |> send_resp(201, "")
    end
  end

  @authorize scopes: ["GP", "EXTERNAL"]
  @decode Proto.Visits.RemoveTimeslotsRequest
  def remove_timeslots(conn, _params) do
    specialist_id = conn.assigns.query_specialist_id
    timeslot_params = conn.assigns.protobuf.timeslot_params

    start_times = Enum.map(timeslot_params, & &1.start_time)

    cmd = %Visits.Commands.RemoveTimeslots{
      specialist_id: specialist_id,
      start_times: start_times
    }

    with :ok <- Visits.remove_timeslots(cmd) do
      conn |> send_resp(200, "")
    end
  end

  @authorize scopes: ["GP", "NURSE", "EXTERNAL"]
  def my_calendar(conn, params) do
    %{"month" => unix} = params
    unix = String.to_integer(unix)

    {:ok, timeslots} =
      Visits.fetch_all_specialist_timeslots(conn.assigns.query_specialist_id, unix)

    conn |> render("my_calendar.proto", %{timeslots: timeslots})
  end
end

defmodule Web.PanelApi.Visits.SpecialistCalendarView do
  use Web, :view

  def render("my_calendar.proto", %{timeslots: timeslots}) do
    %Proto.Visits.GetCalendarResponse{
      timeslots: Enum.map(timeslots, &Web.View.Visits.render_timeslot/1)
    }
  end

  def render("create.proto", %{visit: visit}) do
    %Proto.Visits.CreateVisitResponse{
      record_id: visit.record_id
    }
  end
end
