defmodule Web.PanelApi.Profile.LocationController do
  use Conductor
  use Web, :controller

  action_fallback Web.FallbackController

  @authorize scopes: ["EXTERNAL", "EXTERNAL_REJECTED"]
  def show(conn, _params) do
    specialist_id = conn.assigns.current_specialist_id

    {:ok, location} = SpecialistProfile.fetch_location(specialist_id)

    conn
    |> render("show.proto", %{location: location})
  end

  @authorize scopes: ["EXTERNAL", "EXTERNAL_REJECTED"]
  @decode Proto.SpecialistProfile.UpdateLocationRequest
  def update(conn, _params) do
    specialist_id = conn.assigns.current_specialist_id
    location_proto = conn.assigns.protobuf.location

    params = Map.from_struct(location_proto)

    with {:ok, location} <- SpecialistProfile.update_location(params, specialist_id) do
      conn
      |> render("update.proto", %{location: location})
    end
  end
end
