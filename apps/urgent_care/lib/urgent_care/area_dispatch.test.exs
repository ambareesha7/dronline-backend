defmodule UrgentCare.AreaDispatchTest do
  use Postgres.DataCase, async: false
  alias UrgentCare.AreaDispatch

  @default_team_id 15

  setup do
    Application.put_env(:urgent_care, :default_clinic_id, Integer.to_string(@default_team_id))

    coordinates = %{latitude: 10.0, longitude: 10.0}

    {:ok, %{id: default_team_id}} =
      Teams.create_team(:rand.uniform(1000), %{id: @default_team_id})

    {:ok, %{id: closest_team_id}} =
      Teams.create_team(:rand.uniform(1000), %{
        location: %Geo.Point{
          coordinates: {coordinates.latitude, coordinates.longitude},
          srid: 4326
        }
      })

    {:ok, %{id: closest_team_id_2}} =
      Teams.create_team(:rand.uniform(1000), %{
        location: %Geo.Point{
          coordinates: {coordinates.latitude, coordinates.longitude},
          srid: 4326
        }
      })

    {:ok, %{id: distant_team_id}} =
      Teams.create_team(:rand.uniform(1000), %{
        location: %Geo.Point{coordinates: {50.0, 50.0}, srid: 4326}
      })

    [
      coordinates: coordinates,
      default_team_id: default_team_id,
      closest_team_id: closest_team_id,
      closest_team_id_2: closest_team_id_2,
      distant_team_id: distant_team_id
    ]
  end

  describe "team_ids_in_area/1" do
    test "if flag is enabled, return default clinic", %{
      coordinates: coordinates,
      default_team_id: default_team_id
    } do
      FeatureFlags.enable("default_urgent_care_clinic")

      assert [^default_team_id] = AreaDispatch.team_ids_in_area(coordinates)
    end

    test "if flag is disabled, return clinics by location", %{
      coordinates: coordinates,
      closest_team_id: closest_team_id,
      closest_team_id_2: closest_team_id_2
    } do
      team_ids = AreaDispatch.team_ids_in_area(coordinates)
      assert closest_team_id in team_ids
      assert closest_team_id_2 in team_ids
    end
  end

  describe "closest_clinic_or_hospital/1" do
    test "if flag is enabled, return default clinic", %{
      coordinates: coordinates,
      default_team_id: default_team_id
    } do
      FeatureFlags.enable("default_urgent_care_clinic")

      assert %{id: ^default_team_id} = AreaDispatch.closest_clinic_or_hospital(coordinates)
    end

    test "if flag is disabled, return clinic by location", %{
      coordinates: coordinates,
      closest_team_id: closest_team_id
    } do
      assert %{id: ^closest_team_id} = AreaDispatch.closest_clinic_or_hospital(coordinates)
    end
  end
end
