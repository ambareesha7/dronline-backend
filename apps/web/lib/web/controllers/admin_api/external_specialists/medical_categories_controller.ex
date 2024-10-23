defmodule Web.AdminApi.ExternalSpecialists.MedicalCategoriesController do
  use Web, :controller

  action_fallback Web.FallbackController

  def show(conn, params) do
    specialist_id = params["specialist_id"]

    {:ok, categories} = SpecialistProfile.fetch_medical_categories(specialist_id)

    conn
    |> put_view(Web.AdminApi.Specialists.MedicalCategoriesView)
    |> render("show.proto", %{categories: categories})
  end
end
