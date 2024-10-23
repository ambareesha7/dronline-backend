defmodule Web.Api.Visits.MedicalCategoryCalendarController do
  use Web, :controller

  action_fallback Web.FallbackController

  def show(conn, params) do
    %{"month" => unix, "medical_category_id" => medical_category_id} = params
    medical_category_id = String.to_integer(medical_category_id)
    unix = String.to_integer(unix)
    patient_id = conn.assigns.current_patient_id

    {:ok, medical_category_timeslots} =
      Visits.fetch_free_medical_category_timeslots(medical_category_id, unix, patient_id)

    conn
    |> render("show.proto", %{medical_category_timeslots: medical_category_timeslots})
  end
end

defmodule Web.Api.Visits.MedicalCategoryCalendarView do
  use Web, :view

  def render("show.proto", %{medical_category_timeslots: medical_category_timeslots}) do
    %Proto.Visits.GetMedicalCategoryCalendarResponse{
      medical_category_timeslots:
        Enum.map(medical_category_timeslots, &Web.View.Visits.render_medical_category_timeslot/1)
    }
  end
end
