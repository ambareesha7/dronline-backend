defmodule Web.Api.Specialists.LocationControllerTest do
  use Web.ConnCase, async: true

  alias Proto.SpecialistProfile.GetLocationResponse

  describe "GET show" do
    setup [:authenticate_patient]

    test "returns location when it exists", %{conn: conn} do
      specialist = Authentication.Factory.insert(:specialist)

      SpecialistProfile.Factory.insert(:location,
        specialist_id: specialist.id,
        country: "Germany",
        formatted_address: "123 Test St, 456, Test City, Test Country"
      )

      conn = get(conn, specialists_location_path(conn, :show, specialist.id))

      assert %GetLocationResponse{location: location} =
               proto_response(conn, 200, GetLocationResponse)

      assert location.formatted_address == "123 Test St, 456, Test City, Test Country"
      assert location.country == "Germany"
    end

    test "returns no location when it is missing", %{conn: conn} do
      specialist = Authentication.Factory.insert(:specialist)

      conn = get(conn, specialists_location_path(conn, :show, specialist.id))

      assert %GetLocationResponse{location: location} =
               proto_response(conn, 200, GetLocationResponse)

      assert location == %Proto.SpecialistProfile.Location{
               additional_numbers: "",
               city: "",
               country: "",
               formatted_address: "",
               neighborhood: "",
               number: "",
               postal_code: "",
               street: ""
             }
    end

    test "raises ArgumentError for non-integer specialist id", %{conn: conn} do
      specialist = Authentication.Factory.insert(:specialist)

      SpecialistProfile.Factory.insert(:location,
        specialist_id: specialist.id,
        country: "Germany",
        formatted_address: "123 Test St, 456, Test City, Test Country"
      )

      assert_raise ArgumentError,
                   "errors were found at the given arguments:\n\n  * 1st argument: not a textual representation of an integer\n",
                   fn ->
                     get(conn, specialists_location_path(conn, :show, "wrong id"))
                   end
    end
  end
end
