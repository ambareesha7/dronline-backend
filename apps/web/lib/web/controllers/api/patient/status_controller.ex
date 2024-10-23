defmodule Web.Api.Patient.StatusController do
  use Web, :controller

  action_fallback Web.FallbackController

  def show(conn, _params) do
    patient_id = conn.assigns.current_patient_id

    {:ok, status} = PatientProfile.fetch_status(patient_id)

    conn |> render("show.proto", %{status: status})
  end
end
