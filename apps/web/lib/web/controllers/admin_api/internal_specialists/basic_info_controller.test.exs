defmodule Web.AdminApi.InternalSpecialists.BasicInfoControllerTest do
  use Web.ConnCase, async: true

  alias Proto.SpecialistProfile.GetBasicInfoResponse
  alias Proto.SpecialistProfile.UpdateBasicInfoRequest
  alias Proto.SpecialistProfile.UpdateBasicInfoResponse

  alias Proto.SpecialistProfile.BasicInfo

  describe "GET show" do
    setup [:authenticate_admin]

    test "success when basic info doesn't exist", %{conn: conn} do
      specialist = Authentication.Factory.insert(:verified_specialist, type: "EXTERNAL")

      conn = get(conn, admin_internal_specialists_basic_info_path(conn, :show, specialist.id))

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

      conn = get(conn, admin_internal_specialists_basic_info_path(conn, :show, specialist.id))

      assert %GetBasicInfoResponse{basic_info: %BasicInfo{first_name: "FM"}} =
               proto_response(conn, 200, GetBasicInfoResponse)
    end
  end

  describe "PUT update" do
    setup [:proto_content, :authenticate_admin]

    test "success when basic info doesn't exist", %{conn: conn} do
      specialist = Authentication.Factory.insert(:verified_specialist, type: "EXTERNAL")

      proto =
        %{
          basic_info:
            BasicInfo.new(
              title: :MR |> Proto.Generics.Title.value(),
              first_name: "FN",
              last_name: "LN",
              birth_date: Proto.Generics.DateTime.new(),
              image_url: "http://example.com/image/jpg",
              phone_number: "+48 532 568 641"
            )
        }
        |> UpdateBasicInfoRequest.new()
        |> UpdateBasicInfoRequest.encode()

      conn =
        put(conn, admin_internal_specialists_basic_info_path(conn, :update, specialist.id), proto)

      assert %UpdateBasicInfoResponse{basic_info: %BasicInfo{first_name: "FN"}} =
               proto_response(conn, 200, UpdateBasicInfoResponse)
    end
  end
end
