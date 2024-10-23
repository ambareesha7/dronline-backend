defmodule Web.PanelApi.MedicalCategoryView do
  use Web, :view

  def render("index.proto", %{categories: categories}) do
    %{
      categories:
        render_many(categories, Proto.MedicalCategoriesView, "medical_category_base.proto",
          as: :medical_category
        )
    }
    |> Proto.validate!(Proto.MedicalCategories.GetAllMedicalCategoriesResponse)
    |> Proto.MedicalCategories.GetAllMedicalCategoriesResponse.new()
  end
end
