defmodule Web.PanelApi.Profile.MedicalInfoControllerTest do
  use Web.ConnCase, async: true

  alias Proto.MedicalCategories.MedicalCategoryBase
  alias Proto.SpecialistProfile.MedicalCredentials
  alias Proto.SpecialistProfile.MedicalInfo
  alias Proto.SpecialistProfile.UpdateMedicalInfoRequest
  alias Proto.SpecialistProfile.UpdateMedicalInfoResponse

  describe "PUT update" do
    setup [:proto_content, :authenticate_external]

    test "success when provided data is valid", %{conn: conn} do
      category = SpecialistProfile.Factory.insert(:medical_category)

      proto =
        %{
          medical_info:
            MedicalInfo.new(
              medical_credentials:
                MedicalCredentials.new(
                  dea_number_url: "random_url",
                  dea_number_expiry_date: Proto.Generics.DateTime.new(),
                  board_certification_url: "random_url",
                  board_certification_expiry_date: Proto.Generics.DateTime.new(),
                  current_state_license_number_url: "random_url",
                  current_state_license_number_expiry_date: Proto.Generics.DateTime.new()
                ),
              medical_categories: [
                MedicalCategoryBase.new(
                  id: category.id,
                  name: category.name,
                  parent_category_id: category.parent_category_id
                )
              ]
            )
        }
        |> UpdateMedicalInfoRequest.new()
        |> UpdateMedicalInfoRequest.encode()

      conn = put(conn, panel_profile_medical_info_path(conn, :update), proto)

      assert %UpdateMedicalInfoResponse{
               medical_info: %MedicalInfo{
                 medical_credentials: %MedicalCredentials{dea_number_url: "random_url"},
                 medical_categories: [%MedicalCategoryBase{}]
               }
             } = proto_response(conn, 200, UpdateMedicalInfoResponse)
    end
  end
end
