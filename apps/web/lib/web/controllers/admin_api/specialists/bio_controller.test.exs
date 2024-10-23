defmodule Web.AdminApi.Specialists.BioControllerTest do
  use Web.ConnCase, async: true

  alias Proto.SpecialistProfile.GetBioResponse
  alias Proto.SpecialistProfile.UpdateBioRequest
  alias Proto.SpecialistProfile.UpdateBioResponse

  alias Proto.SpecialistProfile.Bio
  alias Proto.SpecialistProfile.EducationEntry

  describe "GET show" do
    setup [:authenticate_admin]

    test "returns empty bio when it doesn't exist", %{conn: conn} do
      specialist = Authentication.Factory.insert(:specialist)
      conn = get(conn, admin_specialists_bio_path(conn, :show, specialist))

      assert %GetBioResponse{bio: %Bio{description: description}} =
               proto_response(conn, 200, GetBioResponse)

      assert description == ""
    end

    test "returns bio when it exists", %{conn: conn} do
      specialist = Authentication.Factory.insert(:specialist)

      _bio =
        SpecialistProfile.Factory.insert(:bio,
          specialist_id: specialist.id,
          description: "Test Bio"
        )

      conn = get(conn, admin_specialists_bio_path(conn, :show, specialist))

      assert %GetBioResponse{bio: %Bio{description: description}} =
               proto_response(conn, 200, GetBioResponse)

      assert description == "Test Bio"
    end
  end

  describe "PUT update" do
    setup [:proto_content, :authenticate_admin]

    test "updates specialist bio", %{conn: conn} do
      specialist = Authentication.Factory.insert(:specialist)

      proto =
        %{
          bio: Bio.new(description: "Updated bio")
        }
        |> UpdateBioRequest.new()
        |> UpdateBioRequest.encode()

      conn = put(conn, admin_specialists_bio_path(conn, :update, specialist), proto)

      assert %UpdateBioResponse{bio: %Bio{description: description}} =
               proto_response(conn, 200, UpdateBioResponse)

      assert description == "Updated bio"
    end

    test "returns validation errors when provided data is invalid", %{conn: conn} do
      specialist = Authentication.Factory.insert(:specialist)

      proto =
        %{
          bio: %Bio{
            description: "Updated bio",
            education: [EducationEntry.new()]
          }
        }
        |> UpdateBioRequest.new()
        |> UpdateBioRequest.encode()

      conn = put(conn, admin_specialists_bio_path(conn, :update, specialist), proto)

      assert proto_response(conn, 422, Proto.Errors.ErrorResponse)
    end
  end
end
