defmodule Web.AdminApi.ExternalSpecialists.LocationController do
  use Web, :controller

  action_fallback Web.FallbackController

  def show(conn, params) do
    specialist_id = params["specialist_id"]

    {:ok, location} = SpecialistProfile.fetch_location(specialist_id)

    conn
    |> put_view(Web.AdminApi.ExternalSpecialists.LocationView)
    |> render("show.proto", %{location: location})
  end
end
