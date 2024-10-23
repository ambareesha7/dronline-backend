defmodule Web.Api.SpecialistControllerTest do
  use Web.ConnCase, async: true

  alias Proto.SpecialistProfileV2.GetDetailedSpecialistsResponse

  setup [:authenticate_patient]

  describe "#index" do
    setup do
      specialist = Authentication.Factory.insert(:verified_and_approved_external)
      SpecialistProfile.Factory.insert(:basic_info, specialist_id: specialist.id)
      Membership.Factory.insert(:accepted_subscription, specialist_id: specialist.id)

      medical_category = SpecialistProfile.Factory.insert(:medical_category, name: "Allergology")
      SpecialistProfile.update_medical_categories([medical_category.id], specialist.id)

      {:ok, specialist: specialist, medical_category: medical_category}
    end

    test "returns specialists info and medical categories", %{
      conn: conn,
      specialist: specialist,
      medical_category: medical_category
    } do
      assert %GetDetailedSpecialistsResponse{
               detailed_specialists: [
                 %Proto.SpecialistProfileV2.DetailedSpecialist{
                   specialist_generic_data: specialist_generic_data
                 }
               ]
             } =
               conn
               |> get(specialist_path(conn, :index))
               |> proto_response(200, GetDetailedSpecialistsResponse)

      specialist_id = specialist.id
      medical_category_id = medical_category.id

      assert %Proto.Generics.Specialist{
               avatar_url: _,
               deprecated: ["Allergology"],
               first_name: _,
               gender: :MALE,
               id: ^specialist_id,
               last_name: _,
               medical_categories: [
                 %Proto.Generics.Specialist.MedicalCategory{
                   id: ^medical_category_id,
                   name: "Allergology"
                 }
               ],
               medical_title: :UNKNOWN_MEDICAL_TITLE,
               package: :PLATINUM,
               title: :MR,
               type: :EXTERNAL
             } = specialist_generic_data
    end

    test "returns multiple specialists", %{
      conn: conn,
      specialist: %{id: specialist_id},
      medical_category: %{id: medical_category_id},
      current_patient: current_patient
    } do
      %{id: specialist2_id} = Authentication.Factory.insert(:verified_and_approved_external)

      SpecialistProfile.Factory.insert(:basic_info, specialist_id: specialist2_id)
      Membership.Factory.insert(:accepted_subscription, specialist_id: specialist2_id)
      SpecialistProfile.update_medical_categories([medical_category_id], specialist2_id)

      _prices =
        SpecialistProfile.Factory.insert(:prices,
          specialist_id: specialist_id,
          medical_category_id: medical_category_id,
          price_minutes_15: 99
        )

      _prices =
        SpecialistProfile.Factory.insert(:prices,
          specialist_id: specialist2_id,
          medical_category_id: medical_category_id,
          price_minutes_15: 150
        )

      country =
        Postgres.Factory.insert(:country,
          id: "uae",
          name: "Emirates"
        )

      %{id: insurance_provider1_id} =
        Insurance.Factory.insert(:provider, name: "provider_name1", country_id: country.id)

      %{id: insurance_provider2_id} =
        Insurance.Factory.insert(:provider, name: "provider_name2", country_id: country.id)

      SpecialistProfile.Specialist.update_insurance_providers(
        specialist_id,
        [
          insurance_provider1_id,
          insurance_provider2_id
        ]
      )

      SpecialistProfile.Specialist.update_insurance_providers(
        specialist2_id,
        [
          insurance_provider1_id
        ]
      )

      PatientProfile.Factory.insert(:basic_info, patient_id: current_patient.id)

      Insurance.set_patient_insurance(
        %{provider_id: insurance_provider1_id, member_id: "member_id"},
        current_patient.id
      )

      assert %GetDetailedSpecialistsResponse{detailed_specialists: specialists} =
               conn
               |> get(specialist_path(conn, :index))
               |> proto_response(200, GetDetailedSpecialistsResponse)

      [
        %Proto.SpecialistProfileV2.DetailedSpecialist{
          timeslots: [],
          insurance_providers: specialist_providers,
          matching_provider: %Proto.SpecialistProfileV2.MatchingInsuranceProviderV2{
            id: ^insurance_provider1_id,
            name: "provider_name1"
          },
          prices: [
            %Proto.SpecialistProfile.CategoryPricesResponse{
              currency: "AED",
              medical_category_id: ^medical_category_id,
              price_minutes_15: 99
            }
          ],
          specialist_generic_data: %Proto.Generics.Specialist{
            id: ^specialist_id,
            medical_categories: [
              %Proto.Generics.Specialist.MedicalCategory{id: ^medical_category_id}
            ]
          }
        },
        %Proto.SpecialistProfileV2.DetailedSpecialist{
          timeslots: [],
          insurance_providers: [
            %Proto.SpecialistProfileV2.InsuranceProvidersEntryV2{
              country_id: "uae",
              id: ^insurance_provider1_id,
              name: "provider_name1"
            }
          ],
          matching_provider: %Proto.SpecialistProfileV2.MatchingInsuranceProviderV2{
            id: ^insurance_provider1_id,
            name: "provider_name1"
          },
          prices: [
            %Proto.SpecialistProfile.CategoryPricesResponse{
              currency: "AED",
              medical_category_id: ^medical_category_id,
              price_minutes_15: 150
            }
          ],
          specialist_generic_data: %Proto.Generics.Specialist{
            id: ^specialist2_id,
            medical_categories: [
              %Proto.Generics.Specialist.MedicalCategory{id: ^medical_category_id}
            ]
          }
        }
      ] = Enum.sort_by(specialists, &(&1.prices |> List.first() |> Map.get(:price_minutes_15)))

      [
        %Proto.SpecialistProfileV2.InsuranceProvidersEntryV2{
          id: ^insurance_provider1_id,
          name: "provider_name1"
        },
        %Proto.SpecialistProfileV2.InsuranceProvidersEntryV2{
          country_id: "uae",
          id: ^insurance_provider2_id,
          name: "provider_name2"
        }
      ] = specialist_providers |> Enum.sort_by(& &1.name)
    end

    test "returns specialists with prices", %{
      conn: conn,
      specialist: specialist,
      medical_category: medical_category
    } do
      medical_category_id = medical_category.id

      _prices =
        SpecialistProfile.Factory.insert(:prices,
          specialist_id: specialist.id,
          medical_category_id: medical_category_id
        )

      assert %GetDetailedSpecialistsResponse{
               detailed_specialists: [
                 %Proto.SpecialistProfileV2.DetailedSpecialist{prices: prices}
               ]
             } =
               conn
               |> get(specialist_path(conn, :index))
               |> proto_response(200, GetDetailedSpecialistsResponse)

      assert [
               %Proto.SpecialistProfile.CategoryPricesResponse{
                 medical_category_id: ^medical_category_id,
                 medical_category_name: "Allergology",
                 price_minutes_15: 9,
                 prices_enabled: true
               }
             ] = prices
    end

    # TODO Fix after release
    @tag :skip
    test "returns specialists timeslots, only free, maximum 3, in ascending order",
         %{
           conn: conn,
           specialist: specialist
         } do
      %{id: specialist2_id} = Authentication.Factory.insert(:verified_and_approved_external)

      SpecialistProfile.Factory.insert(:basic_info, specialist_id: specialist2_id, title: "MRS")
      Membership.Factory.insert(:accepted_subscription, specialist_id: specialist2_id)

      past_date = Timex.now() |> Timex.shift(minutes: -60)
      tomorrow_date = past_date |> Timex.shift(days: 1)
      after_tomorrow_date = tomorrow_date |> Timex.shift(days: 1)

      timeslot_yesterday = past_date |> Timex.shift(minutes: 15) |> Timex.to_unix()
      timeslot_tomorrow_15 = tomorrow_date |> Timex.shift(minutes: 15) |> Timex.to_unix()
      timeslot_tomorrow_30 = tomorrow_date |> Timex.shift(minutes: 30) |> Timex.to_unix()
      timeslot_tomorrow_45 = tomorrow_date |> Timex.shift(minutes: 45) |> Timex.to_unix()

      timeslot_after_tomorrow_15 =
        after_tomorrow_date |> Timex.shift(minutes: 15) |> Timex.to_unix()

      timeslot_after_tomorrow_30 =
        after_tomorrow_date |> Timex.shift(minutes: 30) |> Timex.to_unix()

      specialist_id = specialist.id

      {:ok, _day_schedule_yesterday} =
        Visits.DaySchedule.insert_or_update(
          %Visits.DaySchedule{specialist_id: specialist_id, date: past_date},
          [
            %{start_time: timeslot_yesterday, visit_type: :ONLINE}
          ],
          []
        )

      {:ok, _day_schedule_tomorrow_id} =
        Visits.DaySchedule.insert_or_update(
          %Visits.DaySchedule{specialist_id: specialist_id, date: tomorrow_date},
          [
            %{start_time: timeslot_tomorrow_15, visit_type: :ONLINE},
            %{start_time: timeslot_tomorrow_30, visit_type: :ONLINE},
            %{start_time: timeslot_tomorrow_45, visit_type: :ONLINE}
          ],
          []
        )

      {:ok, _day_schedule_after_tomorrow_id} =
        Visits.DaySchedule.insert_or_update(
          %Visits.DaySchedule{specialist_id: specialist_id, date: after_tomorrow_date},
          [
            %{start_time: timeslot_after_tomorrow_15, visit_type: :ONLINE},
            %{start_time: timeslot_after_tomorrow_30, visit_type: :ONLINE}
          ],
          []
        )

      {:ok, _day_schedule_today2} =
        Visits.DaySchedule.insert_or_update(
          %Visits.DaySchedule{specialist_id: specialist2_id, date: tomorrow_date},
          [
            %{start_time: timeslot_tomorrow_15, visit_type: :ONLINE},
            %{start_time: timeslot_tomorrow_30, visit_type: :ONLINE}
          ],
          []
        )

      patient = PatientProfile.Factory.insert(:patient)
      _ = PatientProfile.Factory.insert(:basic_info, patient_id: patient.id)

      cmd = %Visits.Commands.TakeTimeslot{
        specialist_id: specialist_id,
        start_time: timeslot_tomorrow_15,
        patient_id: patient.id,
        chosen_medical_category_id: 1,
        visit_type: :ONLINE
      }

      {:ok, _visit} = Visits.take_timeslot(cmd)

      %GetDetailedSpecialistsResponse{
        detailed_specialists: specialists
      } =
        conn
        |> get(specialist_path(conn, :index))
        |> proto_response(200, GetDetailedSpecialistsResponse)

      assert [
               %Proto.SpecialistProfileV2.DetailedSpecialist{
                 timeslots: [
                   %Proto.Visits.Timeslot{
                     start_time: ^timeslot_tomorrow_30,
                     status: {:free, %Proto.Visits.Timeslot.Free{}}
                   },
                   %Proto.Visits.Timeslot{
                     start_time: ^timeslot_tomorrow_45,
                     status: {:free, %Proto.Visits.Timeslot.Free{}}
                   },
                   %Proto.Visits.Timeslot{
                     start_time: ^timeslot_after_tomorrow_15,
                     status: {:free, %Proto.Visits.Timeslot.Free{}}
                   }
                 ]
               },
               %Proto.SpecialistProfileV2.DetailedSpecialist{
                 timeslots: [
                   %Proto.Visits.Timeslot{
                     start_time: ^timeslot_tomorrow_15,
                     status: {:free, %Proto.Visits.Timeslot.Free{}}
                   },
                   %Proto.Visits.Timeslot{
                     start_time: ^timeslot_tomorrow_30,
                     status: {:free, %Proto.Visits.Timeslot.Free{}}
                   }
                 ]
               }
             ] = Enum.sort_by(specialists, & &1.specialist_generic_data.title)
    end

    test "returns specialists with insurance providers", %{
      conn: conn,
      specialist: specialist
    } do
      country =
        Postgres.Factory.insert(:country,
          id: "pl",
          name: "Poland"
        )

      %{id: insurance_provider1_id} =
        Insurance.Factory.insert(:provider, name: "provider_name1", country_id: country.id)

      %{id: insurance_provider2_id} =
        Insurance.Factory.insert(:provider, name: "provider_name2", country_id: country.id)

      SpecialistProfile.Specialist.update_insurance_providers(
        specialist.id,
        [
          insurance_provider1_id,
          insurance_provider2_id
        ]
      )

      assert %GetDetailedSpecialistsResponse{
               detailed_specialists: [
                 %Proto.SpecialistProfileV2.DetailedSpecialist{
                   insurance_providers: insurance_providers
                 }
               ]
             } =
               conn
               |> get(specialist_path(conn, :index))
               |> proto_response(200, GetDetailedSpecialistsResponse)

      assert [
               %Proto.SpecialistProfileV2.InsuranceProvidersEntryV2{
                 country_id: "pl",
                 id: ^insurance_provider1_id,
                 name: "provider_name1"
               },
               %Proto.SpecialistProfileV2.InsuranceProvidersEntryV2{
                 country_id: "pl",
                 id: ^insurance_provider2_id,
                 name: "provider_name2"
               }
             ] = Enum.sort_by(insurance_providers, & &1.name)
    end

    test "returns specialists with matching insurance provider with patient's one", %{
      conn: conn,
      specialist: specialist,
      current_patient: current_patient
    } do
      PatientProfile.Factory.insert(:basic_info, patient_id: current_patient.id)

      country =
        Postgres.Factory.insert(:country,
          id: "pl",
          name: "Poland"
        )

      %{id: insurance_provider1_id} =
        Insurance.Factory.insert(:provider, name: "provider_name1", country_id: country.id)

      %{id: insurance_provider2_id} =
        Insurance.Factory.insert(:provider, name: "provider_name2", country_id: country.id)

      SpecialistProfile.Specialist.update_insurance_providers(
        specialist.id,
        [
          insurance_provider1_id,
          insurance_provider2_id
        ]
      )

      assert %GetDetailedSpecialistsResponse{
               detailed_specialists: [
                 %Proto.SpecialistProfileV2.DetailedSpecialist{
                   matching_provider: %Proto.SpecialistProfileV2.MatchingInsuranceProviderV2{
                     id: 0,
                     name: ""
                   }
                 }
               ]
             } =
               conn
               |> get(specialist_path(conn, :index))
               |> proto_response(200, GetDetailedSpecialistsResponse)

      _patient_insurance =
        Insurance.set_patient_insurance(
          %{provider_id: insurance_provider1_id, member_id: "member_id"},
          current_patient.id
        )

      assert %GetDetailedSpecialistsResponse{
               detailed_specialists: [
                 %Proto.SpecialistProfileV2.DetailedSpecialist{
                   matching_provider: %Proto.SpecialistProfileV2.MatchingInsuranceProviderV2{
                     id: ^insurance_provider1_id,
                     name: "provider_name1"
                   }
                 }
               ]
             } =
               conn
               |> get(specialist_path(conn, :index))
               |> proto_response(200, GetDetailedSpecialistsResponse)
    end

    test "returns specialists by lat/lon", %{conn: conn, specialist: specialist} do
      specialist_id = specialist.id

      SpecialistProfile.Factory.insert(
        :location,
        specialist_id: specialist_id,
        coordinates: %{
          lat: 40.714268,
          lon: -74.005974
        }
      )

      # 8 miles from a Specialist - means Specialist is inside Patient's 100 mile range
      params = %{"lat" => "40.73566", "lon" => "-74.17237"}

      %GetDetailedSpecialistsResponse{
        detailed_specialists: [
          %Proto.SpecialistProfileV2.DetailedSpecialist{
            specialist_generic_data: %{id: ^specialist_id}
          }
        ]
      } =
        conn
        |> get(specialist_path(conn, :index), params)
        |> proto_response(200, GetDetailedSpecialistsResponse)
    end

    test "returns specialists filtered by medical category", %{
      conn: conn,
      medical_category: medical_category,
      specialist: specialist
    } do
      specialist2 = Authentication.Factory.insert(:verified_and_approved_external)
      SpecialistProfile.Factory.insert(:basic_info, specialist_id: specialist2.id)
      Membership.Factory.insert(:accepted_subscription, specialist_id: specialist2.id)
      psychology = SpecialistProfile.Factory.insert(:medical_category, name: "Psychology")
      SpecialistProfile.update_medical_categories([psychology.id], specialist2.id)

      specialist_id = specialist.id
      medical_category_id = medical_category.id
      params = %{"medical_category_id" => medical_category.id}

      %GetDetailedSpecialistsResponse{
        detailed_specialists: [
          %Proto.SpecialistProfileV2.DetailedSpecialist{
            specialist_generic_data: %{
              id: ^specialist_id,
              medical_categories: [
                %Proto.Generics.Specialist.MedicalCategory{
                  id: ^medical_category_id,
                  name: "Allergology"
                }
              ]
            }
          }
        ]
      } =
        conn
        |> get(specialist_path(conn, :index), params)
        |> proto_response(200, GetDetailedSpecialistsResponse)
    end

    test "returns specialists with given ids", %{
      conn: conn,
      medical_category: medical_category,
      specialist: specialist
    } do
      %{id: specialist2_id} = Authentication.Factory.insert(:verified_and_approved_external)
      SpecialistProfile.Factory.insert(:basic_info, specialist_id: specialist2_id)
      Membership.Factory.insert(:accepted_subscription, specialist_id: specialist2_id)
      SpecialistProfile.update_medical_categories([medical_category.id], specialist2_id)

      %{id: specialist3_id} = Authentication.Factory.insert(:verified_and_approved_external)
      SpecialistProfile.Factory.insert(:basic_info, specialist_id: specialist3_id)
      Membership.Factory.insert(:accepted_subscription, specialist_id: specialist3_id)
      SpecialistProfile.update_medical_categories([medical_category.id], specialist3_id)

      assert %GetDetailedSpecialistsResponse{detailed_specialists: specialists} =
               conn
               |> get(specialist_path(conn, :index), %{
                 "ids" => [specialist.id, specialist2_id]
               })
               |> proto_response(200, GetDetailedSpecialistsResponse)

      fetched_specialists_ids = Enum.map(specialists, & &1.specialist_generic_data.id)
      assert Enum.member?(fetched_specialists_ids, specialist.id)
      assert Enum.member?(fetched_specialists_ids, specialist2_id)
    end
  end
end
