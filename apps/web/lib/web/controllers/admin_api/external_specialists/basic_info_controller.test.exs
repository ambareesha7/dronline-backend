defmodule Web.AdminApi.ExternalSpecialists.BasicInfoControllerTest do
  use Web.ConnCase, async: true

  alias Proto.SpecialistProfile.GetBasicInfoResponse

  alias Proto.SpecialistProfile.BasicInfo

  describe "GET show" do
    setup [:authenticate_admin]

    test "success when basic info doesn't exist", %{conn: conn} do
      specialist = Authentication.Factory.insert(:verified_specialist, type: "EXTERNAL")

      conn = get(conn, admin_external_specialists_basic_info_path(conn, :show, specialist.id))

      assert %GetBasicInfoResponse{basic_info: %BasicInfo{}} =
               proto_response(conn, 200, GetBasicInfoResponse)
    end

    test "success when basic info exists", %{conn: conn} do
      specialist = Authentication.Factory.insert(:verified_specialist, type: "EXTERNAL")

      _basicinfo =
        SpecialistProfile.Factory.insert(:basic_info,
          specialist_id: specialist.id,
          first_name: "FM"
        )

      conn = get(conn, admin_external_specialists_basic_info_path(conn, :show, specialist.id))

      assert %GetBasicInfoResponse{basic_info: %BasicInfo{first_name: "FM"}} =
               proto_response(conn, 200, GetBasicInfoResponse)
    end
  end
end
