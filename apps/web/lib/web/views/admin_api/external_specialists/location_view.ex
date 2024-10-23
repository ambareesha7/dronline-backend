defmodule Web.AdminApi.ExternalSpecialists.LocationView do
  use Web, :view

  def render("show.proto", %{location: location}) do
    %{
      location: render_one(location, Proto.SpecialistProfileView, "location.proto", as: :location)
    }
    |> Proto.validate!(Proto.SpecialistProfile.GetLocationResponse)
    |> Proto.SpecialistProfile.GetLocationResponse.new()
  end
end
