defmodule Web.PanelApi.Profile.V2.BasicInfoControllerTest do
  use Web.ConnCase, async: true

  alias Proto.Errors.ErrorResponse
  alias Proto.SpecialistProfileV2.AddressV2
  alias Proto.SpecialistProfileV2.BasicInfoV2
  alias Proto.SpecialistProfileV2.GetBasicInfoResponseV2
  alias Proto.SpecialistProfileV2.UpdateBasicInfoRequestV2
  alias Proto.SpecialistProfileV2.UpdateBasicInfoResponseV2

  describe "GET show" do
    setup [:authenticate_gp]

    test "returns empty basic info if one doesn't exists", %{conn: conn, current_gp: current_gp} do
      {:ok, basic_info} = SpecialistProfile.fetch_basic_info(current_gp.id)
      {:ok, _} = Postgres.Repo.delete(basic_info)

      conn = get(conn, panel_profile_v2_basic_info_path(conn, :show))

      assert %GetBasicInfoResponseV2{basic_info: %BasicInfoV2{}} =
               proto_response(conn, 200, GetBasicInfoResponseV2)
    end

    test "returns basic info if one does exists", %{conn: conn} do
      conn = get(conn, panel_profile_v2_basic_info_path(conn, :show))

      assert %GetBasicInfoResponseV2{basic_info: %BasicInfoV2{address: %AddressV2{}}} =
               proto_response(conn, 200, GetBasicInfoResponseV2)
    end
  end

  describe "PUT update" do
    setup [:proto_content, :authenticate_gp]

    test "success", %{conn: conn} do
      proto =
        %{
          basic_info:
            BasicInfoV2.new(
              first_name: "FN",
              last_name: "LN",
              gender: :MALE |> Proto.Generics.Gender.value(),
              medical_title: :M_D |> Proto.Generics.MedicalTitle.value(),
              birth_date: Proto.Generics.DateTime.new(),
              profile_image_url: "http://example.com/image/jpg",
              phone_number: "+48532568641",
              address:
                AddressV2.new(
                  street: "random_string",
                  number: "random_string",
                  postal_code: "random_string",
                  city: "random_string",
                  country: "random_string",
                  neighborhood: "random_string",
                  formatted_address: "random_string",
                  coordinates:
                    Proto.Generics.Coordinates.new(
                      lat: 80.00001,
                      lon: 20.00001
                    )
                )
            )
        }
        |> UpdateBasicInfoRequestV2.new()
        |> UpdateBasicInfoRequestV2.encode()

      conn = put(conn, panel_profile_v2_basic_info_path(conn, :update), proto)

      assert %UpdateBasicInfoResponseV2{basic_info: %BasicInfoV2{address: %AddressV2{}}} =
               proto_response(conn, 200, UpdateBasicInfoResponseV2)
    end

    test "returns error when invalid params are passed", %{conn: conn} do
      proto =
        %{basic_info: BasicInfoV2.new()}
        |> UpdateBasicInfoRequestV2.new()
        |> UpdateBasicInfoRequestV2.encode()

      conn = put(conn, panel_profile_v2_basic_info_path(conn, :update), proto)

      assert %ErrorResponse{} = proto_response(conn, 422, ErrorResponse)
    end
  end
end
