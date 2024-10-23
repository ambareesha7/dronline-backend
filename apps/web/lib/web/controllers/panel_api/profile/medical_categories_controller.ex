defmodule Web.PanelApi.Profile.MedicalCategoriesController do
  use Conductor
  use Web, :controller

  action_fallback Web.FallbackController

  plug Web.Plugs.AssignQuerySpecialistId, [] when action in [:show]

  @authorize scopes: ["GP", "EXTERNAL", "EXTERNAL_REJECTED"]
  def show(conn, _params) do
    {:ok, categories} =
      SpecialistProfile.fetch_medical_categories(conn.assigns.query_specialist_id)

    conn |> render("show.proto", %{categories: categories})
  end

  @authorize scopes: ["EXTERNAL", "EXTERNAL_REJECTED"]
  @decode Proto.SpecialistProfile.UpdateMedicalCategoriesRequest
  def update(conn, _params) do
    specialist_id = conn.assigns.current_specialist_id
    medical_categories_proto = conn.assigns.protobuf.medical_categories

    categories_ids = medical_categories_proto |> parse_categories_proto()

    with {:ok, categories} <-
           SpecialistProfile.update_medical_categories(categories_ids, specialist_id) do
      conn |> render("update.proto", %{categories: categories})
    end
  end

  defp parse_categories_proto(categories), do: categories |> Enum.map(& &1.id)
end
