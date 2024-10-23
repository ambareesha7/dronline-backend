defmodule Web.Api.Visits.VisitDemandsSpecialistController do
  use Web, :controller

  import Mockery.Macro

  action_fallback Web.FallbackController

  def create(conn, %{"specialist_id" => specialist_id}) do
    specialist_id = String.to_integer(specialist_id)
    patient_id = conn.assigns.current_patient_id

    with {:ok, _} <-
           Visits.Demands.create(%{
             patient_id: patient_id,
             specialist_id: specialist_id
           }),
         :ok <- send_notification(specialist_id) do
      conn
      |> send_resp(201, "")
    end
  end

  def show(conn, %{"specialist_id" => specialist_id}) do
    specialist_id = String.to_integer(specialist_id)
    now = DateTime.utc_now()

    conn
    |> render("visit_demand_availability.proto", %{
      is_visit_demand_available: is_visit_demand_available?(specialist_id, now)
    })
  end

  defp send_notification(specialist_id) do
    case Visits.MonthSchedule.fetch_specialist_timeslots_setup_for_future_without_today(
           specialist_id,
           DateTime.utc_now()
         ) do
      {:ok, []} ->
        mockable(PushNotifications.Message).send(%PushNotifications.Message.VisitDemandRequested{
          send_to_specialist_ids: [specialist_id]
        })

      _ ->
        :ok
    end
  end

  defp is_visit_demand_available?(specialist_id, now) do
    case Visits.MonthSchedule.fetch_specialist_timeslots_setup_for_future_without_today(
           specialist_id,
           now
         ) do
      {:ok, []} -> true
      {:ok, _} -> false
    end
  end
end

defmodule Web.Api.Visits.VisitDemandsSpecialistView do
  def render("visit_demand_availability.proto", %{
        is_visit_demand_available: is_visit_demand_available
      }) do
    %Proto.Visits.GetVisitDemandAvailabilityResponse{
      is_visit_demand_available: is_visit_demand_available
    }
  end
end
