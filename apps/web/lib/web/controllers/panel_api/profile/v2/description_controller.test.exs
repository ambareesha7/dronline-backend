defmodule Web.PanelApi.Profile.V2.DescriptionControllerTest do
  use Web.ConnCase, async: true

  alias Proto.SpecialistProfileV2.GetProfileDescriptionResponseV2
  alias Proto.SpecialistProfileV2.ProfileDescriptionV2
  alias Proto.SpecialistProfileV2.UpdateProfileDescriptionRequestV2
  alias Proto.SpecialistProfileV2.UpdateProfileDescriptionResponseV2

  describe "GET show" do
    setup [:authenticate_gp]

    test "returns empty descrpition if one doesn't exists", %{conn: conn} do
      conn = get(conn, panel_profile_v2_description_path(conn, :show))

      assert %GetProfileDescriptionResponseV2{
               profile_description: %ProfileDescriptionV2{description: ""}
             } = proto_response(conn, 200, GetProfileDescriptionResponseV2)
    end

    test "returns description if it exists", %{conn: conn, current_gp: current_gp} do
      _bio =
        SpecialistProfile.Factory.insert(:bio,
          specialist_id: current_gp.id,
          description: "Test Bio"
        )

      conn = get(conn, panel_profile_v2_description_path(conn, :show))

      assert %GetProfileDescriptionResponseV2{
               profile_description: %ProfileDescriptionV2{description: description}
             } = proto_response(conn, 200, GetProfileDescriptionResponseV2)

      assert description == "Test Bio"
    end
  end

  describe "PUT update" do
    setup [:proto_content, :authenticate_gp]

    test "success", %{conn: conn} do
      proto =
        %{
          profile_description: ProfileDescriptionV2.new(description: "bla bla bla")
        }
        |> UpdateProfileDescriptionRequestV2.new()
        |> UpdateProfileDescriptionRequestV2.encode()

      conn = put(conn, panel_profile_v2_description_path(conn, :update), proto)

      assert %UpdateProfileDescriptionResponseV2{
               profile_description: %ProfileDescriptionV2{description: "bla bla bla"}
             } = proto_response(conn, 200, UpdateProfileDescriptionResponseV2)
    end
  end
end
