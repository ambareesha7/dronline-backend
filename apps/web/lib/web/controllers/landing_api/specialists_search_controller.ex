defmodule Web.LandingApi.Specialists.SearchController do
  use Web, :controller

  action_fallback Web.FallbackController

  def index(conn, params) do
    {:ok, specialist_ids, next_token} = SpecialistProfile.search(params)

    specialists_generic_data_map =
      specialist_ids |> Web.SpecialistGenericData.get_by_ids() |> Map.new(&{&1.specialist.id, &1})

    locations_map =
      specialist_ids |> SpecialistProfile.fetch_locations() |> Map.new(&{&1.specialist_id, &1})

    prices_map =
      specialist_ids
      |> SpecialistProfile.fetch_specialists_prices()
      |> Enum.group_by(& &1.specialist_id)

    {:ok, day_schedules} =
      Visits.fetch_specialists_free_day_schedules_for_future(specialist_ids, DateTime.utc_now())

    day_schedules_map = Enum.group_by(day_schedules, & &1.specialist_id)

    insurance_providers_map =
      specialist_ids
      |> SpecialistProfile.fetch_by_ids_with_insurance_providers()
      |> Enum.group_by(& &1.id, & &1.insurance_providers)

    specialists_data =
      Enum.map(
        specialist_ids,
        &%{
          specialist_generic_data: specialists_generic_data_map[&1],
          location: locations_map[&1],
          prices: prices_map[&1],
          day_schedules: day_schedules_map[&1],
          insurance_providers: List.flatten(insurance_providers_map[&1])
        }
      )

    render(conn, "index.proto", %{
      specialists_data: specialists_data,
      next_token: next_token
    })
  end
end

defmodule Web.LandingApi.Specialists.SearchView do
  use Web, :view

  def render("index.proto", %{
        specialists_data: specialists_data,
        next_token: next_token
      }) do
    %Proto.SpecialistProfileV2.SpecialistsSearchResponse{
      specialists:
        Enum.map(specialists_data, &Web.View.SpecialistProfileV2.render_search_specialist/1),
      next_token: next_token
    }
  end
end
