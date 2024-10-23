defmodule Web.PanelApi.Profile.BasicInfoControllerTest do
  use Web.ConnCase, async: true

  alias Proto.SpecialistProfile.GetBasicInfoResponse
  alias Proto.SpecialistProfile.UpdateBasicInfoRequest
  alias Proto.SpecialistProfile.UpdateBasicInfoResponse

  alias Proto.SpecialistProfile.BasicInfo

  describe "GET show" do
    setup [:authenticate_gp]

    test "success when basic info doesn't exist", %{conn: conn} do
      conn = get(conn, panel_profile_basic_info_path(conn, :show))

      assert %GetBasicInfoResponse{basic_info: %BasicInfo{}} =
               proto_response(conn, 200, GetBasicInfoResponse)
    end

    test "success when basic info exists", %{conn: conn, current_gp: current_gp} do
      _basicinfo =
        SpecialistProfile.Factory.insert(:basic_info,
          specialist_id: current_gp.id,
          first_name: "FM"
        )

      conn = get(conn, panel_profile_basic_info_path(conn, :show))

      assert %GetBasicInfoResponse{basic_info: %BasicInfo{first_name: "FM"}} =
               proto_response(conn, 200, GetBasicInfoResponse)
    end
  end

  describe "PUT update" do
    setup [:proto_content, :authenticate_gp]

    test "success when basic info doesn't exist", %{conn: conn} do
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

      conn = put(conn, panel_profile_basic_info_path(conn, :update), proto)

      assert %UpdateBasicInfoResponse{basic_info: %BasicInfo{first_name: "FN"}} =
               proto_response(conn, 200, UpdateBasicInfoResponse)
    end
  end
end
