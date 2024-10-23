defmodule Web.Api.Specialists.BioControllerTest do
  use Web.ConnCase, async: true

  alias Proto.SpecialistProfile.GetBioResponse

  alias Proto.SpecialistProfile.Bio

  describe "GET show" do
    setup [:authenticate_patient]

    test "returns empty bio when it doesn't exist", %{conn: conn} do
      specialist = Authentication.Factory.insert(:specialist)
      conn = get(conn, specialists_bio_path(conn, :show, specialist))

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

      conn = get(conn, specialists_bio_path(conn, :show, specialist))

      assert %GetBioResponse{bio: %Bio{description: description}} =
               proto_response(conn, 200, GetBioResponse)

      assert description == "Test Bio"
    end
  end
end
