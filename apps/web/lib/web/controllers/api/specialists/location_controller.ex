defmodule Web.Api.Specialists.LocationController do
  use Web, :controller

  action_fallback Web.FallbackController

  def show(conn, params) do
    specialist_id = String.to_integer(params["specialist_id"])

    {:ok, location} = SpecialistProfile.fetch_location(specialist_id)

    conn
    |> render("show.proto", %{location: location})
  end
end

defmodule Web.Api.Specialists.LocationView do
  use Web, :view

  def render("show.proto", %{location: location}) do
    %Proto.SpecialistProfile.GetLocationResponse{
      location: Web.View.SpecialistProfile.render_location(location)
    }
  end
end
