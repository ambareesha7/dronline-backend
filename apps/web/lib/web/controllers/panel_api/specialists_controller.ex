defmodule Web.PanelApi.SpecialistsController do
  use Web, :controller

  action_fallback Web.FallbackController

  def index(conn, params) do
    params = Map.update(params, "membership", "", &String.upcase/1)

    {:ok, specialist_ids, next_token} = SpecialistProfile.fetch_specialists(params)

    specialists_generic_data_map =
      specialist_ids |> Web.SpecialistGenericData.get_by_ids() |> Map.new(&{&1.specialist.id, &1})

    locations_map =
      specialist_ids |> SpecialistProfile.fetch_locations() |> Map.new(&{&1.specialist_id, &1})

    specialists_data =
      Enum.map(
        specialist_ids,
        &%{specialist_generic_data: specialists_generic_data_map[&1], location: locations_map[&1]}
      )

    render(conn, "index.proto", %{
      specialists_data: specialists_data,
      next_token: next_token
    })
  end

  def index_online(conn, params) do
    params = Map.update(params, "membership", "", &String.upcase/1)

    online_specialist_ids = "doctor_presence" |> Web.Presence.list() |> Map.keys()

    {:ok, specialist_ids, next_token} =
      SpecialistProfile.fetch_online_specialists(params, online_specialist_ids)

    specialists_generic_data_map =
      specialist_ids |> Web.SpecialistGenericData.get_by_ids() |> Map.new(&{&1.specialist.id, &1})

    locations_map =
      specialist_ids |> SpecialistProfile.fetch_locations() |> Map.new(&{&1.specialist_id, &1})

    specialists_data =
      Enum.map(
        specialist_ids,
        &%{specialist_generic_data: specialists_generic_data_map[&1], location: locations_map[&1]}
      )

    render(conn, "index.proto", %{
      specialists_data: specialists_data,
      next_token: next_token
    })
  end

  def category(conn, params) do
    category_id = params["category_id"] |> String.to_integer()

    specialists = SpecialistProfile.Specialist.fetch_all_by_category(category_id)
    specialist_ids = Enum.map(specialists, fn {id} -> id end)

    specialists_generic_data = Web.SpecialistGenericData.get_by_ids(specialist_ids)

    render(conn, "category.proto", %{specialists_generic_data: specialists_generic_data})
  end
end

defmodule Web.PanelApi.SpecialistsView do
  use Web, :view

  def render("index.proto", %{
        specialists_data: specialists_data,
        next_token: next_token
      }) do
    %Proto.SpecialistProfile.GetSpecialistsResponse{
      specialists: Enum.map(specialists_data, &Web.View.SpecialistProfile.render_specialist/1),
      next_token: next_token
    }
  end

  def render("category.proto", %{specialists_generic_data: specialists_generic_data}) do
    %Proto.SpecialistProfile.GetSpecialistsInCategoryResponse{
      specialists: Enum.map(specialists_generic_data, &Web.View.Generics.render_specialist/1)
    }
  end
end
