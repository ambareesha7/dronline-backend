defmodule SpecialistProfile.LocationTest do
  use Postgres.DataCase, async: true

  alias SpecialistProfile.Location

  describe "fetch_by_specialist_id/1" do
    test "returns location when specialist_id is valid" do
      specialist = Authentication.Factory.insert(:specialist, type: "EXTERNAL")

      location = SpecialistProfile.Factory.insert(:location, specialist_id: specialist.id)

      {:ok, fetched} = Location.fetch_by_specialist_id(specialist.id)

      assert fetched.id == location.id
    end

    test "returns empty location when specialist_id is invalid" do
      {:ok, %Location{id: nil}} = Location.fetch_by_specialist_id(0)
    end
  end

  describe "update/2" do
    test "creates new location when it doesn't exist" do
      specialist = Authentication.Factory.insert(:specialist, type: "EXTERNAL")

      params = %{
        street: "random_string",
        number: "random_string",
        postal_code: "random_string",
        city: "Poznan",
        country: "random_string",
        neighborhood: "random_string",
        formatted_address: "random_string",
        coordinates: %{
          lat: 80.00001,
          lon: 20.00001
        }
      }

      assert {:ok, %Location{city: "Poznan"}} = Location.update(params, specialist.id)
    end

    test "updates location when it exists" do
      specialist = Authentication.Factory.insert(:specialist, type: "EXTERNAL")

      _basic_info =
        SpecialistProfile.Factory.insert(:location,
          specialist_id: specialist.id,
          city: "Dubai"
        )

      params = %{city: "Poznan"}

      assert {:ok, %Location{city: "Poznan"}} = Location.update(params, specialist.id)
    end
  end
end
