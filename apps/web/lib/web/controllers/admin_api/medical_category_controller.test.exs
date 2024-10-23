defmodule Web.AdminApi.MedicalCategoryControllerTest do
  use Web.ConnCase, async: true

  alias Admin.MedicalCategories.MedicalCategory
  alias Postgres.Repo
  alias Proto.MedicalCategories.GetAllMedicalCategoriesResponse
  alias Proto.MedicalCategories.UpdateMedicalCategoryRequest
  alias Proto.MedicalCategories.UpdateMedicalCategoryResponse

  describe "GET index" do
    setup [:authenticate_admin]

    test "returns all medical categories", %{conn: conn} do
      category1 = %MedicalCategory{name: "Category 1", disabled: false, position: 1}
      category2 = %MedicalCategory{name: "Category 2", disabled: false, position: 2}
      Repo.insert!(category1)
      Repo.insert!(category2)

      conn = get(conn, admin_medical_category_path(conn, :index))

      assert proto_response(conn, 200, GetAllMedicalCategoriesResponse)
    end
  end

  describe "PUT update" do
    setup [:proto_content, :authenticate_admin]

    test "successfully updates a medical category", %{conn: conn} do
      category =
        SpecialistProfile.Factory.insert(:medical_category, name: "Original Name")

      proto =
        %UpdateMedicalCategoryRequest{
          id: category.id,
          disabled: true,
          position: 2
        }
        |> UpdateMedicalCategoryRequest.new()
        |> UpdateMedicalCategoryRequest.encode()

      assert conn
             |> put(
               admin_medical_category_path(conn, :update, category.id),
               proto
             )
             |> proto_response(200, UpdateMedicalCategoryResponse)

      assert updated_category =
               Repo.get_by(MedicalCategory,
                 disabled: true,
                 position: 2
               )

      assert updated_category.disabled == true
      assert updated_category.position == 2
    end
  end
end
