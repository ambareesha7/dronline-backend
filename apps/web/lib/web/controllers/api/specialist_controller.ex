defmodule Web.Api.SpecialistController do
  use Web, :controller

  action_fallback Web.FallbackController

  @day_schedules_limit 3

  def index(conn, params) do
    specialists_ids = params |> convert_coords_to_floats() |> get_doctors_ids()
    patient_id = conn.assigns.current_patient_id

    specialists_generic_data = Web.SpecialistGenericData.get_by_ids(specialists_ids)
    prices = SpecialistProfile.fetch_specialists_prices(specialists_ids)

    {:ok, patient_provider} = Insurance.fetch_by_patient_id(patient_id)

    specialist_providers =
      specialists_ids
      |> SpecialistProfile.fetch_by_ids_with_insurance_providers()
      |> Enum.map(&%{id: &1.id, insurance_providers: &1.insurance_providers})
      |> List.flatten()

    specialists =
      Enum.map(specialists_ids, fn id ->
        %{
          specialist_generic_data: Enum.find(specialists_generic_data, &(&1.specialist.id == id)),
          prices: Enum.filter(prices, &(&1.specialist_id == id)),
          timeslots: get_timeslots(id),
          insurance_providers:
            specialist_providers
            |> Enum.find(&(&1.id == id))
            |> Map.get(:insurance_providers),
          matching_provider: get_matching_provider(patient_provider, specialist_providers)
        }
      end)

    render(conn, "index.proto", %{specialists: specialists})
  end

  defp convert_coords_to_floats(%{
         "lat" => lat,
         "lon" => lon,
         "medical_category_id" => category_id
       }) do
    with {lat, _} <- Float.parse(lat),
         {lon, _} <- Float.parse(lon) do
      %{"lat" => lat, "lon" => lon, "medical_category_id" => category_id}
    end
  end

  defp convert_coords_to_floats(%{"lat" => lat, "lon" => lon}) do
    with {lat, _} <- Float.parse(lat),
         {lon, _} <- Float.parse(lon) do
      %{"lat" => lat, "lon" => lon}
    end
  end

  defp convert_coords_to_floats(params), do: params

  defp get_doctors_ids(%{"ids" => ids}) do
    ids |> Enum.map(&String.to_integer/1)
  end

  defp get_doctors_ids(%{"medical_category_id" => _} = params) do
    {:ok, featured_doctors} = VisitsScheduling.fetch_featured_doctors_for_category(params)
    Enum.map(featured_doctors, & &1.id)
  end

  defp get_doctors_ids(params) do
    {:ok, featured_doctors} = VisitsScheduling.fetch_featured_doctors(params)
    Enum.map(featured_doctors, & &1.id)
  end

  defp get_timeslots(specialist_id) do
    {:ok, timeslots} =
      Visits.fetch_specialist_timeslots_setup_for_future(
        specialist_id,
        DateTime.utc_now()
      )

    timeslots |> Enum.filter(&timeslot_free?/1) |> Enum.take(@day_schedules_limit)
  end

  defp timeslot_free?(%Visits.FreeTimeslot{}), do: true
  defp timeslot_free?(%Visits.TakenTimeslot{}), do: false

  defp get_matching_provider(
         %Insurance.Accounts.Account{} = patient_provider,
         specialist_providers
       ) do
    specialist_providers
    |> Enum.map(& &1.insurance_providers)
    |> List.first()
    |> Enum.map(& &1.id)
    |> Enum.member?(patient_provider.provider_id)
    |> if do
      %{id: patient_provider.provider_id, name: patient_provider.insurance_provider.name}
    else
      %{id: nil, name: nil}
    end
  end

  defp get_matching_provider(_patient_provider, _specialist_providers) do
    %{id: nil, name: nil}
  end
end

defmodule Web.Api.SpecialistView do
  use Web, :view

  def render("index.proto", %{specialists: specialists}) do
    %Proto.SpecialistProfileV2.GetDetailedSpecialistsResponse{
      detailed_specialists:
        Enum.map(specialists, &Web.View.SpecialistProfileV2.render_detailed_specialist/1)
    }
  end
end
