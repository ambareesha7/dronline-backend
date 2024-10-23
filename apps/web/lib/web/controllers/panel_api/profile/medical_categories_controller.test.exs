defmodule Web.PanelApi.Profile.MedicalCategoriesControllerTest do
  use Web.ConnCase, async: true

  alias Proto.SpecialistProfile.GetMedicalCategoriesResponse
  alias Proto.SpecialistProfile.UpdateMedicalCategoriesRequest
  alias Proto.SpecialistProfile.UpdateMedicalCategoriesResponse

  alias Proto.MedicalCategories.MedicalCategoryBase

  describe "GET show" do
    setup [:authenticate_external]

    test "returns medical categories for current doctor", %{
      conn: conn,
      current_external: current_external
    } do
      category = SpecialistProfile.Factory.insert(:medical_category)
      SpecialistProfile.update_medical_categories([category.id], current_external.id)

      conn = get(conn, panel_profile_medical_categories_path(conn, :show))

      assert %GetMedicalCategoriesResponse{} =
               proto_response(conn, 200, GetMedicalCategoriesResponse)
    end
  end

  describe "PUT update" do
    setup [:authenticate_external, :proto_content]

    test "succeeds when params are valid", %{conn: conn} do
      category = SpecialistProfile.Factory.insert(:medical_category)

      proto =
        %{
          medical_categories: [
            MedicalCategoryBase.new(
              id: category.id,
              name: category.name,
              parent_category_id: category.parent_category_id
            )
          ]
        }
        |> UpdateMedicalCategoriesRequest.new()
        |> UpdateMedicalCategoriesRequest.encode()

      conn = put(conn, panel_profile_medical_categories_path(conn, :update), proto)

      assert %UpdateMedicalCategoriesResponse{} =
               proto_response(conn, 200, UpdateMedicalCategoriesResponse)
    end
  end
end
