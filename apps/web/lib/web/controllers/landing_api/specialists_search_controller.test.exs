defmodule Web.LandingApi.Specialists.SearchControllerTest do
  use Web.ConnCase, async: true

  alias Proto.SpecialistProfileV2.SpecialistsSearchResponse

  describe "GET index" do
    setup do
      specialist1 = Authentication.Factory.insert(:verified_and_approved_external)

      _basic_info =
        SpecialistProfile.Factory.insert(:basic_info,
          specialist_id: specialist1.id,
          first_name: "Michael",
          last_name: "Scott"
        )

      location =
        SpecialistProfile.Factory.insert(:location, specialist_id: specialist1.id, country: "USA")

      specialist2 = Authentication.Factory.insert(:verified_and_approved_external)

      _basic_info =
        SpecialistProfile.Factory.insert(:basic_info,
          specialist_id: specialist2.id,
          first_name: "Dwight",
          last_name: "Schrute"
        )

      _location =
        SpecialistProfile.Factory.insert(:location,
          specialist_id: specialist2.id,
          country: "Germany"
        )

      date_now = Timex.now()
      timeslot_date1 = date_now |> Timex.shift(minutes: 60) |> Timex.to_unix()
      timeslot_date2 = date_now |> Timex.shift(minutes: 180) |> Timex.to_unix()

      country =
        Postgres.Factory.insert(:country,
          id: "pl",
          name: "Poland"
        )

      {:ok,
       specialist1: specialist1,
       specialist2: specialist2,
       location_coordinates: location.coordinates,
       date_now: date_now,
       timeslot_date1: timeslot_date1,
       timeslot_date2: timeslot_date2,
       country: country}
    end

    test "returns all specialists when no filter param is given", %{
      conn: conn,
      specialist1: specialist1,
      specialist2: specialist2
    } do
      conn = get(conn, landing_search_path(conn, :index))

      assert %SpecialistsSearchResponse{
               specialists: [fetched_specialist1, fetched_specialist2],
               next_token: ""
             } = proto_response(conn, 200, SpecialistsSearchResponse)

      assert fetched_specialist1.id == specialist1.id
      assert fetched_specialist2.id == specialist2.id
    end

    test "filters specialists by param and returns all fields", %{
      conn: conn,
      specialist1: %{id: specialist1_id},
      location_coordinates: location_coordinates
    } do
      assert %SpecialistsSearchResponse{
               specialists: [fetched_specialist],
               next_token: ""
             } =
               conn
               |> get(landing_search_path(conn, :index, filter: "Michael Scott USA"))
               |> proto_response(200, SpecialistsSearchResponse)

      assert %Proto.SpecialistProfileV2.SearchSpecialist{
               first_name: "Michael",
               id: ^specialist1_id,
               last_name: "Scott",
               day_schedules: [],
               location: %Proto.SpecialistProfileV2.AddressV2{
                 coordinates: fetched_location_coordinates,
                 country: "USA"
               },
               package: :BASIC,
               type: :EXTERNAL
             } = fetched_specialist

      assert {Float.round(fetched_location_coordinates.lat, 5),
              Float.round(fetched_location_coordinates.lon, 5)} ==
               location_coordinates.coordinates
    end

    test "filters specialists by filter param and returns all fields including single prices, day schedule, medical category and insurance provider",
         %{
           conn: conn,
           specialist1: %{id: specialist1_id},
           specialist2: %{id: specialist2_id},
           timeslot_date1: timeslot_date1,
           timeslot_date2: timeslot_date2,
           date_now: date_now,
           country: country
         } do
      {:ok, _day_schedule} =
        Visits.DaySchedule.insert_or_update(
          %Visits.DaySchedule{specialist_id: specialist1_id, date: date_now},
          [
            %{start_time: timeslot_date1, visit_type: :ONLINE},
            %{start_time: timeslot_date2, visit_type: :ONLINE}
          ],
          []
        )

      {:ok, _day_schedule} =
        Visits.DaySchedule.insert_or_update(
          %Visits.DaySchedule{specialist_id: specialist2_id, date: date_now},
          [
            %{start_time: timeslot_date1, visit_type: :ONLINE},
            %{start_time: timeslot_date2, visit_type: :ONLINE}
          ],
          []
        )

      %{id: neurology_id} = SpecialistProfile.Factory.insert(:medical_category, name: "Neurology")
      SpecialistProfile.update_medical_categories([neurology_id], specialist1_id)

      %{id: hepatology_id} =
        SpecialistProfile.Factory.insert(:medical_category, name: "Hepatology")

      SpecialistProfile.update_medical_categories([hepatology_id], specialist2_id)

      %{price_minutes_15: price_minutes_15} =
        SpecialistProfile.Factory.insert(:prices,
          specialist_id: specialist1_id,
          medical_category_id: neurology_id
        )

      _prices =
        SpecialistProfile.Factory.insert(:prices,
          specialist_id: specialist2_id,
          medical_category_id: neurology_id
        )

      %{id: insurance_provider1_id} =
        Insurance.Factory.insert(:provider, name: "provider_name1", country_id: country.id)

      %{id: insurance_provider2_id} =
        Insurance.Factory.insert(:provider, name: "provider_name2", country_id: country.id)

      SpecialistProfile.Specialist.update_insurance_providers(
        specialist1_id,
        [
          insurance_provider1_id
        ]
      )

      SpecialistProfile.Specialist.update_insurance_providers(
        specialist2_id,
        [
          insurance_provider2_id
        ]
      )

      assert %SpecialistsSearchResponse{
               specialists: [fetched_specialist],
               next_token: ""
             } =
               conn
               |> get(landing_search_path(conn, :index, filter: "Michael Scott USA"))
               |> proto_response(200, SpecialistsSearchResponse)

      assert %Proto.SpecialistProfileV2.SearchSpecialist{
               categories_prices: [
                 %Proto.SpecialistProfile.CategoryPricesResponse{
                   medical_category_id: ^neurology_id,
                   medical_category_name: "Neurology",
                   price_minutes_15: ^price_minutes_15
                 }
               ],
               id: ^specialist1_id,
               day_schedules: [
                 %Proto.Visits.DaySchedule{
                   free_timeslots: [
                     %Proto.Visits.Timeslot{
                       start_time: ^timeslot_date1,
                       status: {:free, %Proto.Visits.Timeslot.Free{}}
                     },
                     %Proto.Visits.Timeslot{
                       start_time: ^timeslot_date2,
                       status: {:free, %Proto.Visits.Timeslot.Free{}}
                     }
                   ],
                   free_timeslots_count: 2,
                   specialist_id: ^specialist1_id,
                   taken_timeslots: [],
                   taken_timeslots_count: 0
                 }
               ],
               insurance_providers: [
                 %Proto.SpecialistProfileV2.InsuranceProvidersEntryV2{
                   id: ^insurance_provider1_id,
                   name: "provider_name1"
                 }
               ],
               medical_categories: [
                 %Proto.Generics.Specialist.MedicalCategory{id: ^neurology_id, name: "Neurology"}
               ]
             } = fetched_specialist
    end

    test "filters specialists by filter param and returns all fields including multiple prices, day schedules, medical categories and insurance providers",
         %{
           conn: conn,
           specialist1: %{id: specialist1_id},
           timeslot_date1: timeslot_date1,
           timeslot_date2: timeslot_date2,
           date_now: date_now,
           country: country
         } do
      date_tomorrow = date_now |> Timex.shift(days: 1)

      {:ok, %{id: day_schedule_today_id}} =
        Visits.DaySchedule.insert_or_update(
          %Visits.DaySchedule{specialist_id: specialist1_id, date: date_now},
          [
            %{start_time: timeslot_date1, visit_type: :ONLINE},
            %{start_time: timeslot_date2, visit_type: :ONLINE}
          ],
          []
        )

      {:ok, %{id: day_schedule_tomorrow_id}} =
        Visits.DaySchedule.insert_or_update(
          %Visits.DaySchedule{specialist_id: specialist1_id, date: date_tomorrow},
          [%{start_time: timeslot_date1, visit_type: :ONLINE}],
          []
        )

      %{id: neurology_id} = SpecialistProfile.Factory.insert(:medical_category, name: "Neurology")
      SpecialistProfile.update_medical_categories([neurology_id], specialist1_id)

      %{id: hepatology_id} =
        SpecialistProfile.Factory.insert(:medical_category, name: "Hepatology")

      SpecialistProfile.update_medical_categories([hepatology_id], specialist1_id)

      %{price_minutes_15: neurology_price_minutes_15} =
        SpecialistProfile.Factory.insert(:prices,
          specialist_id: specialist1_id,
          medical_category_id: neurology_id,
          currency: "USD"
        )

      %{price_minutes_15: hepatology_price_minutes_15} =
        SpecialistProfile.Factory.insert(:prices,
          specialist_id: specialist1_id,
          medical_category_id: hepatology_id,
          currency: "AED"
        )

      %{id: insurance_provider1_id} =
        Insurance.Factory.insert(:provider, name: "provider_name1", country_id: country.id)

      %{id: insurance_provider2_id} =
        Insurance.Factory.insert(:provider, name: "provider_name2", country_id: country.id)

      SpecialistProfile.Specialist.update_insurance_providers(
        specialist1_id,
        [
          insurance_provider1_id,
          insurance_provider2_id
        ]
      )

      assert %SpecialistsSearchResponse{
               specialists: [fetched_specialist],
               next_token: ""
             } =
               conn
               |> get(landing_search_path(conn, :index, filter: "Michael Scott USA"))
               |> proto_response(200, SpecialistsSearchResponse)

      assert %Proto.SpecialistProfileV2.SearchSpecialist{
               categories_prices: categories_prices,
               id: ^specialist1_id,
               day_schedules: [
                 %Proto.Visits.DaySchedule{
                   free_timeslots: [
                     %Proto.Visits.Timeslot{
                       start_time: ^timeslot_date1,
                       status: {:free, %Proto.Visits.Timeslot.Free{}}
                     },
                     %Proto.Visits.Timeslot{
                       start_time: ^timeslot_date2,
                       status: {:free, %Proto.Visits.Timeslot.Free{}}
                     }
                   ],
                   free_timeslots_count: 2,
                   id: ^day_schedule_today_id,
                   specialist_id: ^specialist1_id,
                   taken_timeslots: [],
                   taken_timeslots_count: 0
                 },
                 %Proto.Visits.DaySchedule{
                   free_timeslots: [
                     %Proto.Visits.Timeslot{
                       start_time: ^timeslot_date1,
                       status: {:free, %Proto.Visits.Timeslot.Free{}}
                     }
                   ],
                   free_timeslots_count: 1,
                   id: ^day_schedule_tomorrow_id,
                   specialist_id: ^specialist1_id,
                   taken_timeslots: [],
                   taken_timeslots_count: 0
                 }
               ],
               insurance_providers: [
                 %Proto.SpecialistProfileV2.InsuranceProvidersEntryV2{
                   id: ^insurance_provider1_id,
                   name: "provider_name1"
                 },
                 %Proto.SpecialistProfileV2.InsuranceProvidersEntryV2{
                   id: ^insurance_provider2_id,
                   name: "provider_name2"
                 }
               ],
               medical_categories: medical_categories
             } = fetched_specialist

      assert [
               %Proto.Generics.Specialist.MedicalCategory{
                 id: ^hepatology_id,
                 name: "Hepatology"
               },
               %Proto.Generics.Specialist.MedicalCategory{id: ^neurology_id, name: "Neurology"}
             ] = Enum.sort_by(medical_categories, & &1.name)

      assert [
               %Proto.SpecialistProfile.CategoryPricesResponse{
                 medical_category_id: ^hepatology_id,
                 medical_category_name: "Hepatology",
                 price_minutes_15: ^hepatology_price_minutes_15,
                 currency: "AED"
               },
               %Proto.SpecialistProfile.CategoryPricesResponse{
                 medical_category_id: ^neurology_id,
                 medical_category_name: "Neurology",
                 price_minutes_15: ^neurology_price_minutes_15,
                 currency: "USD"
               }
             ] = Enum.sort_by(categories_prices, & &1.medical_category_name)
    end
  end
end
