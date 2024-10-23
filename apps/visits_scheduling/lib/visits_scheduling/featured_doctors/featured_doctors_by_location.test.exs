defmodule VisitsScheduling.FeaturedDoctorsByLocationTest do
  use Postgres.DataCase, async: true

  alias VisitsScheduling.FeaturedDoctors

  describe "if [lat, lon] parameters are used" do
    test "returns featured doctors additionally filtered and ordered by proximity" do
      [
        coordinates: {
          new_york_lat,
          new_york_lon
        },
        specialists: [
          specialist_1,
          specialist_2,
          specialist_3,
          specialist_4,
          specialist_5
        ]
      ] = setup_shared()

      #  I. FeaturedDoctors.fetch

      assert {:ok, featured_doctors} =
               FeaturedDoctors.fetch(%{
                 "lat" => new_york_lat,
                 "lon" => new_york_lon
               })

      assert [
               response_specialist_1,
               response_specialist_2,
               response_specialist_3,
               response_specialist_4,
               response_specialist_5
             ] = featured_doctors

      assert [
               response_specialist_1.id,
               response_specialist_2.id,
               response_specialist_3.id,
               response_specialist_4.id,
               response_specialist_5.id
             ] == [
               specialist_1.id,
               specialist_3.id,
               specialist_4.id,
               specialist_5.id,
               specialist_2.id
             ]

      #  II.  FeaturedDoctors.fetch_for_category
      category_1 = SpecialistProfile.Factory.insert(:medical_category, name: "Category 1")
      category_2 = SpecialistProfile.Factory.insert(:medical_category, name: "Category 2")

      assign_category_to_specialist(category_1.id, specialist_1.id)
      assign_category_to_specialist(category_1.id, specialist_2.id)
      assign_category_to_specialist(category_1.id, specialist_3.id)

      # These Specialists should be filtered out by Category
      assign_category_to_specialist(category_2.id, specialist_4.id)
      assign_category_to_specialist(category_2.id, specialist_5.id)

      assert {:ok, featured_doctors} =
               FeaturedDoctors.fetch_for_category(%{
                 "medical_category_id" => category_1.id,
                 "lat" => new_york_lat,
                 "lon" => new_york_lon
               })

      assert [
               response_specialist_1,
               response_specialist_2,
               response_specialist_3
             ] = featured_doctors

      assert [
               response_specialist_1.id,
               response_specialist_2.id,
               response_specialist_3.id
             ] == [
               specialist_1.id,
               specialist_3.id,
               specialist_2.id
             ]
    end
  end

  defp setup_shared do
    new_york_lat = 40.714268
    new_york_lon = -74.005974

    # Distances taken from here:
    # https://www.distance.to/New-York/Newark,NJ,USA

    specialist_1 = %{id: id} = insert_specialist()
    insert_basic_info(id)
    insert_subscription(id)
    insert_location(id, "New York, NY, USA", {new_york_lat, new_york_lon})

    # 5 miles
    # because it's "SILVER" ("SILVER" < "PLATINUM"),
    # it'll always come after "PLATINUM" Specialists
    specialist_2 = %{id: id} = insert_specialist()
    insert_basic_info(id)
    insert_subscription(id, "SILVER")
    insert_location(id, "Brooklyn, NY, USA", {40.650002, -73.949997})

    # 8 miles
    specialist_3 = %{id: id} = insert_specialist()
    insert_basic_info(id)
    insert_subscription(id)
    insert_location(id, "Newark, NJ, USA", {40.73566, -74.17237})

    # 80 miles
    specialist_4 = %{id: id} = insert_specialist()
    insert_basic_info(id)
    insert_subscription(id)
    insert_location(id, "Philadelphia, PA, USA", {39.952583, -75.165222})

    # 95 miles
    specialist_5 = %{id: id} = insert_specialist()
    insert_basic_info(id)
    insert_subscription(id)
    insert_location(id, "Atlantic-City, NJ, USA", {39.364285, -74.422935})

    # 104 miles (out of range)
    _specialist_6 = %{id: id} = insert_specialist()
    insert_basic_info(id)
    insert_subscription(id)
    insert_location(id, "Hazleton, PA, USA", {40.958420, -75.974650})

    # 1500 miles (out of range)
    _specialist_7 = %{id: id} = insert_specialist()
    insert_basic_info(id)
    insert_subscription(id)
    insert_location(id, "Texas City, TX, USA", {31.000000, -100.000000})

    [
      coordinates: {
        new_york_lat,
        new_york_lon
      },
      specialists: [
        specialist_1,
        specialist_2,
        specialist_3,
        specialist_4,
        specialist_5
      ]
    ]
  end

  defp insert_location(specialist_id, name, {lat, lon}) do
    SpecialistProfile.Factory.insert(
      :location,
      specialist_id: specialist_id,
      formatted_address: name,
      coordinates: %{
        lat: lat,
        lon: lon
      }
    )
  end

  defp insert_specialist do
    Authentication.Factory.insert(:verified_and_approved_external)
  end

  defp insert_subscription(specialist_id, subscription_type \\ "PLATINUM") do
    Membership.Factory.insert(:accepted_subscription,
      specialist_id: specialist_id,
      type: subscription_type
    )
  end

  defp insert_basic_info(specialist_id) do
    SpecialistProfile.Factory.insert(:basic_info, specialist_id: specialist_id)
  end

  defp assign_category_to_specialist(category_id, specialist_id) do
    {:ok, _} =
      SpecialistProfile.Specialist.update_categories(
        [
          category_id
        ],
        specialist_id
      )
  end
end
