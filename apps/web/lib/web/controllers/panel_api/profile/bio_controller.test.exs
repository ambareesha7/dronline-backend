defmodule Web.PanelApi.Profile.BioControllerTest do
  use Web.ConnCase, async: true

  alias Proto.SpecialistProfile.GetBioResponse
  alias Proto.SpecialistProfile.UpdateBioRequest
  alias Proto.SpecialistProfile.UpdateBioResponse

  alias Proto.SpecialistProfile.Bio
  alias Proto.SpecialistProfile.EducationEntry

  describe "GET show" do
    setup [:authenticate_gp]

    test "returns empty bio when it doesn't exist", %{conn: conn} do
      conn = get(conn, panel_profile_bio_path(conn, :show))

      assert %GetBioResponse{bio: %Bio{description: description}} =
               proto_response(conn, 200, GetBioResponse)

      assert description == ""
    end

    test "returns bio when it exists", %{conn: conn, current_gp: current_gp} do
      _bio =
        SpecialistProfile.Factory.insert(:bio,
          specialist_id: current_gp.id,
          description: "Test Bio"
        )

      conn = get(conn, panel_profile_bio_path(conn, :show))

      assert %GetBioResponse{bio: %Bio{description: description}} =
               proto_response(conn, 200, GetBioResponse)

      assert description == "Test Bio"
    end
  end

  describe "PUT update" do
    setup [:proto_content, :authenticate_gp]

    test "updates specialist bio", %{conn: conn} do
      proto =
        %{
          bio: Bio.new(description: "Updated bio")
        }
        |> UpdateBioRequest.new()
        |> UpdateBioRequest.encode()

      conn = put(conn, panel_profile_bio_path(conn, :update), proto)

      assert %UpdateBioResponse{bio: %Bio{description: description}} =
               proto_response(conn, 200, UpdateBioResponse)

      assert description == "Updated bio"
    end

    test "returns validation errors when provided data is invalid", %{conn: conn} do
      proto =
        %{
          bio: %Bio{
            description: "Updated bio",
            education: [EducationEntry.new()]
          }
        }
        |> UpdateBioRequest.new()
        |> UpdateBioRequest.encode()

      conn = put(conn, panel_profile_bio_path(conn, :update), proto)

      assert proto_response(conn, 422, Proto.Errors.ErrorResponse)
    end
  end
end
