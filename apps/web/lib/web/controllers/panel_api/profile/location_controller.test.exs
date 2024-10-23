defmodule Web.PanelApi.Profile.LocationControllerTest do
  use Web.ConnCase, async: true

  alias Proto.SpecialistProfile.GetLocationResponse
  alias Proto.SpecialistProfile.UpdateLocationRequest
  alias Proto.SpecialistProfile.UpdateLocationResponse

  alias Proto.SpecialistProfile.Location

  describe "GET show" do
    setup [:authenticate_external]

    test "success when location doesn't exist", %{conn: conn} do
      conn = get(conn, panel_profile_location_path(conn, :show))

      assert %GetLocationResponse{location: %Location{}} =
               proto_response(conn, 200, GetLocationResponse)
    end

    test "success when location exists", %{conn: conn, current_external: current_external} do
      _location =
        SpecialistProfile.Factory.insert(:location,
          specialist_id: current_external.id,
          city: "Poznan"
        )

      conn = get(conn, panel_profile_location_path(conn, :show))

      assert %GetLocationResponse{location: %Location{city: "Poznan"}} =
               proto_response(conn, 200, GetLocationResponse)
    end
  end

  describe "PUT update" do
    setup [:proto_content, :authenticate_external]

    test "success when location doesn't exist", %{conn: conn} do
      proto =
        %{
          location:
            Location.new(
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
        }
        |> UpdateLocationRequest.new()
        |> UpdateLocationRequest.encode()

      conn = put(conn, panel_profile_location_path(conn, :update), proto)

      assert %UpdateLocationResponse{
               location: %Location{street: "random_string"}
             } = proto_response(conn, 200, UpdateLocationResponse)
    end

    test "success when location exist", %{
      conn: conn,
      current_external: current_external
    } do
      _location =
        SpecialistProfile.Factory.insert(:location,
          specialist_id: current_external.id
        )

      proto =
        %{
          location:
            Location.new(
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
        }
        |> UpdateLocationRequest.new()
        |> UpdateLocationRequest.encode()

      conn = put(conn, panel_profile_location_path(conn, :update), proto)

      assert %UpdateLocationResponse{
               location: %Location{street: "random_string"}
             } = proto_response(conn, 200, UpdateLocationResponse)
    end
  end
end
