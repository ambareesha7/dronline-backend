defmodule Web.PanelApi.MedicalCategoryControllerTest do
  use Web.ConnCase, async: true

  alias Proto.MedicalCategories.GetAllMedicalCategoriesResponse

  describe "GET index" do
    setup [:authenticate_gp]

    test "succeds", %{conn: conn} do
      root_category = SpecialistProfile.Factory.insert(:medical_category)

      _category =
        SpecialistProfile.Factory.insert(:medical_category, parent_category_id: root_category.id)

      conn = get(conn, panel_medical_category_path(conn, :index))

      assert %GetAllMedicalCategoriesResponse{categories: categories} =
               proto_response(conn, 200, GetAllMedicalCategoriesResponse)

      assert length(categories) == 2
    end
  end
end
