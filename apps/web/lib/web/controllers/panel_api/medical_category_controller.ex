defmodule Web.PanelApi.MedicalCategoryController do
  use Web, :controller

  def index(conn, _params) do
    {:ok, categories} = SpecialistProfile.MedicalCategories.MedicalCategory.fetch_all()

    conn |> render("index.proto", %{categories: categories})
  end
end
