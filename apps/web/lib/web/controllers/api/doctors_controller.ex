defmodule Web.Api.DoctorsController do
  use Web, :controller

  action_fallback Web.FallbackController

  # this controller will be depracated in favour of Web.Api.SpecialistController,
  # but we can keep it here for some time due to backward compatibility
  # also we are not using "doctor" anymore in terms of code and business, we stick to "specialist"

  # deprecated
  def featured_doctors(conn, params) do
    params = convert_coords_to_floats(params)

    {:ok, featured_doctors} = VisitsScheduling.fetch_featured_doctors(params)
    # TODO optimize this shit
    doctor_ids = Enum.map(featured_doctors, & &1.id)

    specialists_generic_data = Web.SpecialistGenericData.get_by_ids(doctor_ids)

    conn
    |> render("featured_doctors.proto", %{specialists_generic_data: specialists_generic_data})
  end

  def favourite_providers(conn, _params) do
    patient_id = conn.assigns.current_patient_id
    {:ok, doctor_ids} = EMR.fetch_patient_specialists_ids(patient_id)

    specialists_generic_data = Web.SpecialistGenericData.get_by_ids(doctor_ids)

    conn
    |> render("favourite_providers.proto", %{specialists_generic_data: specialists_generic_data})
  end

  # deprecated
  def doctors_details(conn, params) do
    %{"ids" => ids} = params
    ids = ids |> String.split(",") |> Enum.map(&String.to_integer/1)

    specialists_generic_data = Web.SpecialistGenericData.get_by_ids(ids)

    conn |> render("doctors_details.proto", %{specialists_generic_data: specialists_generic_data})
  end

  defp convert_coords_to_floats(%{"lat" => lat, "lon" => lon}) do
    with {lat, _} <- Float.parse(lat),
         {lon, _} <- Float.parse(lon) do
      %{"lat" => lat, "lon" => lon}
    end
  end

  defp convert_coords_to_floats(params), do: params
end

defmodule Web.Api.DoctorsView do
  use Web, :view

  def render("featured_doctors.proto", %{specialists_generic_data: specialists_generic_data}) do
    %Proto.Doctors.GetFeaturedDoctorsResponse{
      featured_doctors: Enum.map(specialists_generic_data, &Web.View.Generics.render_specialist/1)
    }
  end

  def render("favourite_providers.proto", %{specialists_generic_data: specialists_generic_data}) do
    %Proto.Doctors.GetFavouriteProvidersResponse{
      favourite_providers:
        Enum.map(specialists_generic_data, &Web.View.Generics.render_specialist/1)
    }
  end

  def render("doctors_details.proto", %{specialists_generic_data: specialists_generic_data}) do
    %Proto.Doctors.GetDoctorsDetailsResponse{
      doctors_details: Enum.map(specialists_generic_data, &Web.View.Generics.render_specialist/1)
    }
  end
end
