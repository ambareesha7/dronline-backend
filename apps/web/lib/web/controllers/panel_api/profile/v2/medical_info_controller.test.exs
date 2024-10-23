defmodule Web.PanelApi.Profile.V2.MedicalInfoControllerTest do
  use Web.ConnCase, async: true

  alias Proto.SpecialistProfileV2.GetMedicalInfoResponseV2
  alias Proto.SpecialistProfileV2.MedicalCredentialsV2
  alias Proto.SpecialistProfileV2.MedicalInfoV2
  alias Proto.SpecialistProfileV2.UpdateMedicalInfoRequestV2
  alias Proto.SpecialistProfileV2.UpdateMedicalInfoResponseV2

  describe "GET show" do
    setup [:authenticate_gp]

    test "successfully returns medical info for given specialist", %{conn: conn} do
      conn = get(conn, panel_profile_v2_medical_info_path(conn, :show))

      assert %GetMedicalInfoResponseV2{medical_info: %MedicalInfoV2{}} =
               proto_response(conn, 200, GetMedicalInfoResponseV2)
    end
  end

  describe "PUT update" do
    setup [:proto_content, :authenticate_external]

    test "success", %{conn: conn} do
      category = SpecialistProfile.Factory.insert(:medical_category)

      proto =
        %{
          medical_info:
            MedicalInfoV2.new(
              medical_credentials:
                MedicalCredentialsV2.new(
                  board_certification_url: "random_url",
                  board_certification_expiry_date: Proto.Generics.DateTime.new(),
                  current_state_license_number_url: "random_url",
                  current_state_license_number_expiry_date: Proto.Generics.DateTime.new()
                ),
              medical_categories: [
                Proto.MedicalCategories.MedicalCategoryBase.new(
                  id: category.id,
                  name: category.name,
                  parent_category_id: category.parent_category_id
                )
              ]
            )
        }
        |> UpdateMedicalInfoRequestV2.new()
        |> UpdateMedicalInfoRequestV2.encode()

      conn = put(conn, panel_profile_v2_medical_info_path(conn, :update), proto)

      assert %UpdateMedicalInfoResponseV2{medical_info: %MedicalInfoV2{}} =
               proto_response(conn, 200, UpdateMedicalInfoResponseV2)
    end
  end
end
