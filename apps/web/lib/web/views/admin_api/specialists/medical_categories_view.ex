defmodule Web.AdminApi.Specialists.MedicalCategoriesView do
  use Web, :view

  def render("show.proto", %{categories: categories}) do
    %{
      medical_categories:
        render_many(categories, Proto.MedicalCategoriesView, "medical_category_base.proto",
          as: :medical_category
        )
    }
    |> Proto.validate!(Proto.SpecialistProfile.GetMedicalCategoriesResponse)
    |> Proto.SpecialistProfile.GetMedicalCategoriesResponse.new()
  end

  def render("update.proto", %{categories: categories}) do
    %{
      medical_categories:
        render_many(categories, Proto.MedicalCategoriesView, "medical_category_base.proto",
          as: :medical_category
        )
    }
    |> Proto.validate!(Proto.SpecialistProfile.UpdateMedicalCategoriesResponse)
    |> Proto.SpecialistProfile.UpdateMedicalCategoriesResponse.new()
  end
end
