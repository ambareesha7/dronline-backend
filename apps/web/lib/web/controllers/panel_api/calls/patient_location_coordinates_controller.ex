defmodule Web.PanelApi.Calls.PatientLocationCoordinatesController do
  use Conductor
  use Web, :controller

  action_fallback(Web.FallbackController)

  @authorize scope: "GP"
  def show(conn, params) do
    call_id = params["call_id"]

    case Calls.Call.get_patient_location_coordinates(call_id) do
      {:error, :invalid_call_id} ->
        render(conn, "show.proto", %{coordinates: nil})

      coordinates ->
        render(conn, "show.proto", %{coordinates: coordinates})
    end
  end
end

defmodule Web.PanelApi.Calls.PatientLocationCoordinatesView do
  use Web, :view

  def render("show.proto", %{coordinates: nil}) do
    %Proto.Calls.GetPatientLocationCoordinatesResponse{}
  end

  def render("show.proto", %{coordinates: coordinates}) do
    %Proto.Calls.GetPatientLocationCoordinatesResponse{
      patient_location_coordinates: Web.View.Generics.render_coordinates(coordinates)
    }
  end
end
