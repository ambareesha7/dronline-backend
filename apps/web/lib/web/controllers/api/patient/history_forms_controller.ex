defmodule Web.Api.Patient.HistoryFormsController do
  use Web, :controller

  action_fallback Web.FallbackController

  def show(conn, _params) do
    patient_id = conn.assigns.current_patient_id

    {:ok, history_forms} = PatientProfile.fetch_history_forms(patient_id)

    conn |> render("show.proto", %{history_forms: history_forms})
  end

  @decode Proto.PatientProfile.UpdateHistoryRequest
  def update(conn, _params) do
    patient_id = conn.assigns.current_patient_id
    update_proto = conn.assigns.protobuf.updated

    with {:ok, history_forms} <- PatientProfile.update_history_forms(update_proto, patient_id) do
      conn |> render("update.proto", %{history_forms: history_forms})
    end
  end
end
