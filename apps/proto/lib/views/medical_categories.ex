defmodule Proto.MedicalCategoriesView do
  use Proto.View

  def render("medical_category.proto", %{medical_category: medical_category}) do
    %{
      id: medical_category.id,
      name: medical_category.name,
      image_url: medical_category.image_url,
      what_we_treat_url: medical_category.what_we_treat_url,
      icon_url: medical_category.icon_url,
      visit_type: Proto.enum(medical_category.visit_type, Proto.MedicalCategories.MedicalCategory.VisitType)
    }
    |> Proto.validate!(Proto.MedicalCategories.MedicalCategory)
    |> Proto.MedicalCategories.MedicalCategory.new()
  end

  def render("medical_category_base.proto", %{medical_category: medical_category}) do
    %{
      id: medical_category.id,
      name: medical_category.name,
      parent_category_id: medical_category.parent_category_id
    }
    |> Proto.validate!(Proto.MedicalCategories.MedicalCategoryBase)
    |> Proto.MedicalCategories.MedicalCategoryBase.new()
  end
end
