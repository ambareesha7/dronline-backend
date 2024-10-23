defmodule Web.Api.Calls.AvailabilityController do
  use Web, :controller

  def local_clinic(conn, %{"lat" => lat, "lon" => lon}) do
    clinic =
      UrgentCare.closest_clinic_or_hospital(%{
        latitude: String.to_float(lat),
        longitude: String.to_float(lon)
      })

    render(conn, "local_clinic.proto", %{clinic: clinic})
  end
end
