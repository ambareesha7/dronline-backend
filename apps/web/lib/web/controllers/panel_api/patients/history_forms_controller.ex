defmodule Web.PanelApi.Patients.HistoryFormsController do
  use Web, :controller

  action_fallback Web.FallbackController

  plug Web.Plugs.RequireOnboarding

  def show(conn, params) do
    %{"patient_id" => patient_id} = params

    {:ok, history_forms} = PatientProfile.fetch_history_forms(patient_id)

    conn
    |> put_view(Web.Api.Patient.HistoryFormsView)
    |> render("show.proto", %{history_forms: history_forms})
  end

  @decode Proto.PatientProfile.UpdateHistoryRequest
  def update(conn, params) do
    %{"patient_id" => patient_id} = params
    patient_id = String.to_integer(patient_id)
    update_proto = conn.assigns.protobuf.updated

    with {:ok, history_forms} <- PatientProfile.update_history_forms(update_proto, patient_id) do
      conn
      |> put_view(Web.Api.Patient.HistoryFormsView)
      |> render("update.proto", %{history_forms: history_forms})
    end
  end

  @decode Proto.PatientProfile.UpdateAllHistoryRequest
  def update_all(conn, params) do
    %{"patient_id" => patient_id} = params
    patient_id = String.to_integer(patient_id)
    update_proto = conn.assigns.protobuf

    with {:ok, history_forms} <- PatientProfile.update_all_history_forms(update_proto, patient_id) do
      conn
      |> put_view(Web.Api.Patient.HistoryFormsView)
      |> render("update.proto", %{history_forms: history_forms})
    end
  end
end
