defmodule Web.AdminApi.InternalSpecialists.MedicalCategoriesControllerTest do
  use Web.ConnCase, async: true

  alias Proto.SpecialistProfile.GetMedicalCategoriesResponse

  describe "GET show" do
    setup [:authenticate_admin]

    test "returns medical categories for current doctor", %{conn: conn} do
      specialist = Authentication.Factory.insert(:verified_specialist, type: "EXTERNAL")

      category = SpecialistProfile.Factory.insert(:medical_category)
      SpecialistProfile.update_medical_categories([category.id], specialist.id)

      conn =
        get(conn, admin_internal_specialists_medical_categories_path(conn, :show, specialist.id))

      assert %GetMedicalCategoriesResponse{} =
               proto_response(conn, 200, GetMedicalCategoriesResponse)
    end
  end
end
