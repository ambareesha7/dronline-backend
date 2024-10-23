defmodule Web.Api.EMR.VitalsController do
  use Web, :controller

  action_fallback Web.FallbackController

  def show(conn, _params) do
    patient_id = conn.assigns.current_patient_id

    vitals = EMR.get_latest_vitals(patient_id)

    specialists_generic_data =
      case vitals do
        nil ->
          []

        %{provided_by_nurse_id: nurse_id} ->
          Web.SpecialistGenericData.get_by_ids([nurse_id])
      end

    conn
    |> render("show.proto", %{
      vitals: vitals,
      specialists_generic_data: specialists_generic_data
    })
  end

  def history(conn, params) do
    patient_id = conn.assigns.current_patient_id

    {:ok, vitals_history, next_token} = EMR.fetch_vitals_history(patient_id, params)

    specialists_generic_data = get_specialists_genric_data(vitals_history)

    conn
    |> render("history.proto", %{
      vitals_history: vitals_history,
      specialists_generic_data: specialists_generic_data,
      next_token: next_token
    })
  end

  def history_for_record(conn, params) do
    patient_id = conn.assigns.current_patient_id
    record_id = String.to_integer(params["record_id"])

    {:ok, vitals_history, next_token} =
      EMR.fetch_vitals_history_for_record(patient_id, record_id, params)

    specialists_generic_data = get_specialists_genric_data(vitals_history)

    conn
    |> render("history.proto", %{
      vitals_history: vitals_history,
      specialists_generic_data: specialists_generic_data,
      next_token: next_token
    })
  end

  defp get_specialists_genric_data(vitals_history) do
    vitals_history
    |> Enum.map(& &1.provided_by_nurse_id)
    |> Enum.uniq()
    |> Web.SpecialistGenericData.get_by_ids()
  end
end

defmodule Web.Api.EMR.VitalsView do
  use Web, :view

  def render("show.proto", %{vitals: vitals, specialists_generic_data: specialists_generic_data}) do
    %Proto.EMR.GetVitalsResponse{
      vitals: Web.View.EMR.render_vitals(vitals),
      specialists: Enum.map(specialists_generic_data, &Web.View.Generics.render_specialist/1)
    }
  end

  def render("history.proto", %{
        vitals_history: vitals_history,
        specialists_generic_data: specialists_generic_data,
        next_token: next_token
      }) do
    %Proto.EMR.GetVitalsHistoryResponse{
      vitals_history: Enum.map(vitals_history, &Web.View.EMR.render_vitals/1),
      specialists: Enum.map(specialists_generic_data, &Web.View.Generics.render_specialist/1),
      next_token: next_token
    }
  end
end
