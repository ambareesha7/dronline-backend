defmodule Web.Api.Visits.VisitDemandsCategoryController do
  use Web, :controller

  import Mockery.Macro

  action_fallback(Web.FallbackController)

  def create(conn, %{"medical_category_id" => medical_category_id}) do
    medical_category_id = String.to_integer(medical_category_id)
    patient_id = conn.assigns.current_patient_id
    now = DateTime.utc_now()

    with {:ok, _} <-
           Visits.Demands.create(%{
             patient_id: patient_id,
             medical_category_id: medical_category_id
           }),
         {:ok, busy_specialist_ids} <-
           Visits.MonthSchedule.fetch_specialists_with_timeslots_setup_for_future(
             medical_category_id,
             now
           ),
         specialist_ids <- fetch_specialist_ids(medical_category_id, busy_specialist_ids),
         :ok <- send_notification(specialist_ids) do
      conn
      |> send_resp(201, "")
    end
  end

  def show(conn, %{"medical_category_id" => medical_category_id}) do
    medical_category_id = String.to_integer(medical_category_id)
    now = DateTime.utc_now()

    conn
    |> render("visit_demand_availability.proto", %{
      is_visit_demand_available: is_visit_demand_available?(medical_category_id, now)
    })
  end

  defp is_visit_demand_available?(medical_category_id, now) do
    medical_category_id
    |> Visits.MonthSchedule.fetch_free_timeslots_for_medical_category(now)
    |> case do
      {:ok, []} ->
        {:ok, busy_specialist_ids} =
          Visits.MonthSchedule.fetch_specialists_with_timeslots_setup_for_future(
            medical_category_id,
            now
          )

        specialist_ids = fetch_specialist_ids(medical_category_id, busy_specialist_ids)
        specialist_ids != []

      {:ok, _} ->
        false
    end
  end

  defp fetch_specialist_ids(medical_category_id, busy_specialist_ids) do
    medical_category_id
    |> SpecialistProfile.Specialist.fetch_all_by_category()
    |> Enum.map(fn {id} -> id end)
    |> Enum.reject(fn id -> id in busy_specialist_ids end)
  end

  defp send_notification(specialist_ids) do
    mockable(PushNotifications.Message).send(%PushNotifications.Message.VisitDemandRequested{
      send_to_specialist_ids: specialist_ids
    })
  end
end

defmodule Web.Api.Visits.VisitDemandsCategoryView do
  def render("visit_demand_availability.proto", %{
        is_visit_demand_available: is_visit_demand_available
      }) do
    %Proto.Visits.GetVisitDemandAvailabilityResponse{
      is_visit_demand_available: is_visit_demand_available
    }
  end
end
