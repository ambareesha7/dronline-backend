defmodule Web.PanelApi.EMR.VitalsController do
  use Conductor
  use Web, :controller

  action_fallback Web.FallbackController

  plug Web.Plugs.VerifySpecialistPatientConnection, param_name: "patient_id"

  @authorize scopes: ["GP", "NURSE", "EXTERNAL"]
  @decode Proto.EMR.CreateNewVitalsRequest
  def create(conn, params) do
    patient_id = String.to_integer(params["patient_id"])
    record_id = String.to_integer(params["record_id"])
    nurse_id = conn.assigns.current_specialist_id

    params = Web.Parsers.EMR.VitalsParams.to_map_params(conn.assigns.protobuf.vitals_params)

    with {:ok, vitals} <- EMR.add_newest_vitals(patient_id, record_id, nurse_id, params) do
      specialists_generic_data =
        Web.SpecialistGenericData.get_by_ids([vitals.provided_by_nurse_id])

      conn
      |> render("create.proto", %{
        vitals: vitals,
        specialists_generic_data: specialists_generic_data
      })
    end
  end

  @authorize scopes: ["GP", "NURSE", "EXTERNAL"]
  def show(conn, params) do
    patient_id = String.to_integer(params["patient_id"])

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

  @authorize scopes: ["GP", "NURSE", "EXTERNAL"]
  def history(conn, params) do
    patient_id = String.to_integer(params["patient_id"])

    {:ok, vitals_history, next_token} = EMR.fetch_vitals_history(patient_id, params)

    specialists_generic_data =
      vitals_history
      |> Enum.map(& &1.provided_by_nurse_id)
      |> Enum.uniq()
      |> Web.SpecialistGenericData.get_by_ids()

    conn
    |> render("history.proto", %{
      vitals_history: vitals_history,
      specialists_generic_data: specialists_generic_data,
      next_token: next_token
    })
  end
end

defmodule Web.PanelApi.EMR.VitalsView do
  use Web, :view

  def render("create.proto", %{vitals: vitals, specialists_generic_data: specialists_generic_data}) do
    %Proto.EMR.CreateNewVitalsResponse{
      vitals: Web.View.EMR.render_vitals(vitals),
      specialists: Enum.map(specialists_generic_data, &Web.View.Generics.render_specialist/1)
    }
  end

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
