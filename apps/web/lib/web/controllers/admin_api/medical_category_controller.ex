defmodule Web.AdminApi.MedicalCategoryController do
  use Web, :controller
  alias Admin.MedicalCategories.MedicalCategory
  action_fallback Web.FallbackController

  def index(conn, _params) do
    {:ok, categories} = MedicalCategory.fetch_all()

    render(conn, "index.proto", %{categories: categories})
  end

  @decode Proto.MedicalCategories.UpdateMedicalCategoryRequest
  def update(conn, _params) do
    id = conn.assigns.protobuf.id
    medical_category_params = Map.from_struct(conn.assigns.protobuf)

    {:ok, category} =
      MedicalCategory.update(id, medical_category_params)

    render(conn, "update.proto", %{category: category})
  end
end
