defmodule Web.Api.MedicalCategoryController do
  use Web, :controller

  action_fallback Web.FallbackController

  def index(conn, _params) do
    {:ok, categories} = VisitsScheduling.fetch_medical_categories_root()

    conn
    |> render("index.proto", %{
      categories: categories
    })
  end

  def show(conn, params) do
    %{"id" => category_id} = params

    with {:ok, category} <- VisitsScheduling.fetch_medical_category(category_id) do
      {:ok, subcategories} = VisitsScheduling.fetch_medical_subcategories(category_id)

      conn |> render("show.proto", %{category: category, subcategories: subcategories})
    end
  end

  # this endpoint will be depracated in favour of Web.Api.SpecialistController,
  # but we can keep it here for some time due to backward compatibility
  def featured_doctors(conn, params) do
    params = convert_coords_to_floats(params)

    {:ok, featured_doctors} = VisitsScheduling.fetch_featured_doctors_for_category(params)
    # TODO optimize this shit
    doctor_ids = Enum.map(featured_doctors, & &1.id)

    specialists_generic_data = Web.SpecialistGenericData.get_by_ids(doctor_ids)

    conn
    |> render("featured_doctors.proto", %{specialists_generic_data: specialists_generic_data})
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

  defp convert_coords_to_floats(params), do: params
end

defmodule Web.Api.MedicalCategoryView do
  use Web, :view

  def render("index.proto", %{categories: categories}) do
    %Proto.MedicalCategories.GetMedicalCategoriesResponse{
      categories:
        render_many(
          categories,
          Proto.MedicalCategoriesView,
          "medical_category.proto",
          as: :medical_category
        )
    }
  end

  def render("show.proto", %{category: category, subcategories: subcategories}) do
    %Proto.MedicalCategories.GetMedicalCategoryResponse{
      category:
        render_one(
          category,
          Proto.MedicalCategoriesView,
          "medical_category.proto",
          as: :medical_category
        ),
      subcategories:
        render_many(
          subcategories,
          Proto.MedicalCategoriesView,
          "medical_category.proto",
          as: :medical_category
        )
    }
  end

  def render("featured_doctors.proto", %{specialists_generic_data: specialists_generic_data}) do
    %Proto.MedicalCategories.GetMedicalCategoryFeaturedDoctorsResponse{
      featured_doctors: Enum.map(specialists_generic_data, &Web.View.Generics.render_specialist/1)
    }
  end
end
