defmodule Web.AdminApi.ExternalSpecialists.LocationControllerTest do
  use Web.ConnCase, async: true

  alias Proto.SpecialistProfile.GetLocationResponse

  alias Proto.SpecialistProfile.Location

  describe "GET show" do
    setup [:authenticate_admin]

    test "success when basic info doesn't exist", %{conn: conn} do
      specialist = Authentication.Factory.insert(:verified_specialist, type: "EXTERNAL")

      conn = get(conn, admin_external_specialists_location_path(conn, :show, specialist.id))

      assert %GetLocationResponse{location: %Location{}} =
               proto_response(conn, 200, GetLocationResponse)
    end

    test "success when basic info exists", %{conn: conn} do
      specialist = Authentication.Factory.insert(:verified_specialist, type: "EXTERNAL")

      _location =
        SpecialistProfile.Factory.insert(:location,
          specialist_id: specialist.id,
          street: "street"
        )

      conn = get(conn, admin_external_specialists_location_path(conn, :show, specialist.id))

      assert %GetLocationResponse{location: %Location{street: "street"}} =
               proto_response(conn, 200, GetLocationResponse)
    end
  end
end
