defmodule Visits.MonthScheduleTest do
  use Postgres.DataCase, async: true

  alias Visits.DaySchedule
  alias Visits.MonthSchedule

  @minutes_in_timeslot 15
  @seconds_in_minute 60
  @seconds_in_timeslot @minutes_in_timeslot * @seconds_in_minute

  defp start_times(start_time, count) when is_integer(start_time) do
    for i <- 0..(count - 1) do
      start_time + i * @seconds_in_timeslot
    end
  end

  defp start_times(start_time, count) do
    start_time
    |> Timex.to_unix()
    |> start_times(count)
  end

  describe "fetch_all_timeslots/2" do
    test "returns all (free and taken) timeslots for given specialist" do
      specialist_id = 1
      date = ~D[2100-11-30]
      [start_time1, start_time2] = start_times(date, 2)

      {:ok, _day_schedule} =
        DaySchedule.insert_or_update(
          %DaySchedule{specialist_id: specialist_id, date: date},
          [%{start_time: start_time1, visit_type: :ONLINE}],
          [
            %{
              id: UUID.uuid4(),
              start_time: start_time2,
              patient_id: 1,
              record_id: 1,
              visit_id: UUID.uuid4(),
              visit_type: :ONLINE
            }
          ]
        )

      assert {:ok, [%{start_time: ^start_time1}, %{start_time: ^start_time2}]} =
               MonthSchedule.fetch_all_timeslots(specialist_id, Timex.to_unix(date))
    end

    test "returns timeslots from valid range (given month, one day before and one day after)" do
      specialist_id = 1

      [
        ~N[2100-10-30T12:00:00],
        ~N[2100-10-31T12:00:00],
        ~N[2100-11-15T12:00:00],
        ~N[2100-12-01T12:00:00],
        ~N[2100-12-02T12:00:00]
      ]
      |> Enum.each(fn naive_datetime ->
        date = Timex.to_date(naive_datetime)
        start_time = Timex.to_unix(naive_datetime)

        {:ok, _day_schedule} =
          DaySchedule.insert_or_update(
            %DaySchedule{specialist_id: specialist_id, date: date},
            [%{start_time: start_time, visit_type: :ONLINE}],
            []
          )
      end)

      assert {:ok, [first, second, last] = _free_slots_in_range} =
               MonthSchedule.fetch_all_timeslots(specialist_id, Timex.to_unix(~D[2100-11-10]))

      assert first.start_time == Timex.to_unix(~N[2100-10-31T12:00:00])
      assert second.start_time == Timex.to_unix(~N[2100-11-15T12:00:00])
      assert last.start_time == Timex.to_unix(~N[2100-12-01T12:00:00])
    end

    test "doesn't return free timeslots from the past" do
      specialist_id = 1

      date = ~D[1992-11-15]
      [start_time1, start_time2] = start_times(date, 2)

      {:ok, _day_schedule} =
        DaySchedule.insert_or_update(
          %DaySchedule{specialist_id: specialist_id, date: date},
          [%{start_time: start_time1, visit_type: :ONLINE}],
          [
            %{
              id: UUID.uuid4(),
              start_time: start_time2,
              patient_id: 1,
              record_id: 1,
              visit_id: UUID.uuid4(),
              visit_type: :ONLINE
            }
          ]
        )

      assert {:ok, [taken_slot]} =
               MonthSchedule.fetch_all_timeslots(specialist_id, Timex.to_unix(date))

      assert taken_slot.start_time == Timex.to_unix(~N[1992-11-15T00:15:00])
    end
  end

  describe "fetch_free_timeslots/2" do
    test "returns only free timeslots for given specialist" do
      specialist_id = 1

      date = ~D[2100-11-15]
      [start_time1, start_time2] = start_times(date, 2)

      {:ok, _day_schedule} =
        DaySchedule.insert_or_update(
          %DaySchedule{specialist_id: specialist_id, date: date},
          [%{start_time: start_time1, visit_type: :ONLINE}],
          [
            %{
              id: UUID.uuid4(),
              start_time: start_time2,
              patient_id: 1,
              record_id: 1,
              visit_id: UUID.uuid4(),
              visit_type: :ONLINE
            }
          ]
        )

      assert {:ok, [%{start_time: ^start_time1}]} =
               MonthSchedule.fetch_free_timeslots(specialist_id, Timex.to_unix(date), 1)
    end

    test "returns timeslots from valid date range" do
      specialist_id = 1

      [
        ~N[2100-10-30T12:00:00],
        ~N[2100-10-31T12:00:00],
        ~N[2100-11-15T12:00:00],
        ~N[2100-12-01T12:00:00],
        ~N[2100-12-02T12:00:00]
      ]
      |> Enum.each(fn naive_datetime ->
        date = Timex.to_date(naive_datetime)
        start_time = Timex.to_unix(naive_datetime)

        {:ok, _day_schedule} =
          DaySchedule.insert_or_update(
            %DaySchedule{specialist_id: specialist_id, date: date},
            [%{start_time: start_time, visit_type: :ONLINE}],
            []
          )
      end)

      assert {:ok, [first, second, last] = _free_slots_in_range} =
               MonthSchedule.fetch_free_timeslots(specialist_id, Timex.to_unix(~D[2100-11-10]), 1)

      assert first.start_time == Timex.to_unix(~N[2100-10-31T12:00:00])
      assert second.start_time == Timex.to_unix(~N[2100-11-15T12:00:00])
      assert last.start_time == Timex.to_unix(~N[2100-12-01T12:00:00])
    end

    test "doesn't return timeslots from the past" do
      specialist_id = 1

      date = ~D[1992-11-15]
      [start_time] = start_times(date, 1)

      {:ok, _day_schedule} =
        DaySchedule.insert_or_update(
          %DaySchedule{specialist_id: specialist_id, date: date},
          [%{start_time: start_time, visit_type: :ONLINE}],
          []
        )

      assert {:ok, [] = _free_slots_in_range} =
               MonthSchedule.fetch_free_timeslots(specialist_id, start_time, 1)
    end

    test "doesn't return slot if Patient has Pending Visit with same start time" do
      specialist_id = 1

      date = ~D[2100-11-15]
      [start_time1, _] = start_times(date, 2)

      {:ok, _day_schedule} =
        DaySchedule.insert_or_update(
          %DaySchedule{specialist_id: specialist_id, date: date},
          [%{start_time: start_time1, visit_type: :ONLINE}],
          []
        )

      {:ok, _pending_visit} =
        Visits.PendingVisit.create(%{
          chosen_medical_category_id: 1,
          patient_id: 1,
          record_id: 1,
          specialist_id: 1,
          start_time: start_time1,
          visit_type: :ONLINE
        })

      assert {:ok, []} = MonthSchedule.fetch_free_timeslots(specialist_id, Timex.to_unix(date), 1)
    end
  end

  describe "fetch_free_timeslots_for_medical_category/3" do
    setup do
      specialist = Authentication.Factory.insert(:verified_and_approved_external)
      medical_category = SpecialistProfile.Factory.insert(:medical_category)

      SpecialistProfile.update_medical_categories([medical_category.id], specialist.id)

      {:ok, specialist_id: specialist.id, medical_category_id: medical_category.id}
    end

    test "returns only free timeslots", %{
      specialist_id: specialist_id,
      medical_category_id: medical_category_id
    } do
      date = ~D[2100-11-15]
      [start_time1, start_time2] = start_times(date, 2)

      {:ok, _day_schedule} =
        DaySchedule.insert_or_update(
          %DaySchedule{specialist_id: specialist_id, date: date},
          [%{start_time: start_time1, visit_type: :ONLINE}],
          [
            %{
              id: UUID.uuid4(),
              start_time: start_time2,
              patient_id: 1,
              record_id: 1,
              visit_id: UUID.uuid4(),
              visit_type: :ONLINE
            }
          ]
        )

      medical_category_timeslot = %{
        start_time: start_time1,
        available_specialist_ids: [specialist_id]
      }

      unix = Timex.to_unix(date)

      assert {:ok, [^medical_category_timeslot] = _free_slots_in_range} =
               MonthSchedule.fetch_free_timeslots_for_medical_category(
                 medical_category_id,
                 unix,
                 1
               )
    end

    test "returns free timeslots for all specialists of given medical category", %{
      specialist_id: specialist1_id,
      medical_category_id: medical_category_id
    } do
      specialist2 = Authentication.Factory.insert(:verified_and_approved_external)
      SpecialistProfile.update_medical_categories([medical_category_id], specialist2.id)

      date = ~D[2100-11-15]
      [start_time] = start_times(date, 1)

      {:ok, _day_schedule} =
        DaySchedule.insert_or_update(
          %DaySchedule{specialist_id: specialist1_id, date: date},
          [%{start_time: start_time, visit_type: :ONLINE}],
          []
        )

      {:ok, _day_schedule} =
        DaySchedule.insert_or_update(
          %DaySchedule{specialist_id: specialist2.id, date: date},
          [%{start_time: start_time, visit_type: :ONLINE}],
          []
        )

      unix = Timex.to_unix(date)

      assert {:ok,
              [%{start_time: ^start_time, available_specialist_ids: available_specialist_ids}]} =
               MonthSchedule.fetch_free_timeslots_for_medical_category(
                 medical_category_id,
                 unix,
                 1
               )

      assert specialist1_id in available_specialist_ids
      assert specialist2.id in available_specialist_ids
    end

    test "doesn't return free timeslots from different medical category", %{
      specialist_id: specialist1_id,
      medical_category_id: medical_category1_id
    } do
      specialist2 = Authentication.Factory.insert(:verified_and_approved_external)
      medical_category2 = SpecialistProfile.Factory.insert(:medical_category)
      SpecialistProfile.update_medical_categories([medical_category2.id], specialist2.id)

      date = ~D[2100-11-15]
      start_time = ~N[2100-11-15T12:00:00] |> Timex.to_unix()

      medical_category_timeslot = %{
        start_time: start_time,
        available_specialist_ids: [specialist1_id]
      }

      {:ok, _day_schedule} =
        DaySchedule.insert_or_update(
          %DaySchedule{specialist_id: specialist1_id, date: date},
          [%{start_time: start_time, visit_type: :ONLINE}],
          []
        )

      {:ok, _day_schedule} =
        DaySchedule.insert_or_update(
          %DaySchedule{specialist_id: specialist2.id, date: date},
          [%{start_time: start_time, visit_type: :ONLINE}],
          []
        )

      unix = Timex.to_unix(~D[2100-11-10])

      result =
        MonthSchedule.fetch_free_timeslots_for_medical_category(medical_category1_id, unix, 1)

      assert {:ok, [^medical_category_timeslot] = _free_slots_in_range} = result
    end

    test "returns timeslots from valid date range", %{
      specialist_id: specialist_id,
      medical_category_id: medical_category_id
    } do
      [
        ~N[2100-10-30T12:00:00],
        ~N[2100-10-31T12:00:00],
        ~N[2100-11-15T12:00:00],
        ~N[2100-12-01T12:00:00],
        ~N[2100-12-02T12:00:00]
      ]
      |> Enum.map(fn naive_datetime ->
        date = Timex.to_date(naive_datetime)
        start_time = Timex.to_unix(naive_datetime)

        {:ok, _day_schedule} =
          DaySchedule.insert_or_update(
            %DaySchedule{specialist_id: specialist_id, date: date},
            [%{start_time: start_time, visit_type: :ONLINE}],
            []
          )
      end)

      unix = Timex.to_unix(~D[2100-11-10])

      result =
        MonthSchedule.fetch_free_timeslots_for_medical_category(medical_category_id, unix, 1)

      assert {:ok, [first, second, last] = _free_slots_in_range} = result

      assert first.start_time == Timex.to_unix(~N[2100-10-31T12:00:00])
      assert second.start_time == Timex.to_unix(~N[2100-11-15T12:00:00])
      assert last.start_time == Timex.to_unix(~N[2100-12-01T12:00:00])
    end

    test "doesn't return timeslots from the past", %{
      specialist_id: specialist_id,
      medical_category_id: medical_category_id
    } do
      [
        ~N[2018-10-30T12:00:00],
        ~N[2018-10-31T12:00:00],
        ~N[2018-11-15T12:00:00],
        ~N[2018-12-01T12:00:00],
        ~N[2018-12-02T12:00:00]
      ]
      |> Enum.map(fn naive_datetime ->
        date = Timex.to_date(naive_datetime)
        start_time = Timex.to_unix(naive_datetime)

        {:ok, _day_schedule} =
          DaySchedule.insert_or_update(
            %DaySchedule{specialist_id: specialist_id, date: date},
            [%{start_time: start_time, visit_type: :ONLINE}],
            []
          )
      end)

      unix = Timex.to_unix(~D[2018-11-10])

      result =
        MonthSchedule.fetch_free_timeslots_for_medical_category(medical_category_id, unix, 1)

      assert {:ok, [] = _free_slots_in_range} = result
    end

    test "doesn't return slot if Patient has Pending Visit with same start time", %{
      specialist_id: specialist_id,
      medical_category_id: medical_category_id
    } do
      date = ~D[2100-11-15]
      [start_time1, _] = start_times(date, 2)

      {:ok, _day_schedule} =
        DaySchedule.insert_or_update(
          %DaySchedule{specialist_id: specialist_id, date: date},
          [%{start_time: start_time1, visit_type: :ONLINE}],
          []
        )

      {:ok, _pending_visit} =
        Visits.PendingVisit.create(%{
          chosen_medical_category_id: 1,
          patient_id: 1,
          record_id: 1,
          specialist_id: 1,
          start_time: start_time1,
          visit_type: :ONLINE
        })

      assert {:ok, []} =
               MonthSchedule.fetch_free_timeslots_for_medical_category(
                 medical_category_id,
                 Timex.to_unix(date),
                 1
               )
    end
  end

  describe "fetch_specialists_with_timeslots_setup_for_future/2" do
    test "returns list of specialists with free slots setup in the future" do
      specialist1 = Authentication.Factory.insert(:verified_and_approved_external)
      specialist2 = Authentication.Factory.insert(:verified_and_approved_external)
      medical_category = SpecialistProfile.Factory.insert(:medical_category)

      # Setup specialist medical category
      _ =
        Repo.insert_all("specialists_medical_categories", [
          %{specialist_id: specialist1.id, medical_category_id: medical_category.id},
          %{specialist_id: specialist2.id, medical_category_id: medical_category.id}
        ])

      # Setup slots for specialists
      date = ~D[2100-11-15]
      [start_time1, start_time2] = start_times(date, 2)

      {:ok, _day_schedule} =
        DaySchedule.insert_or_update(
          %DaySchedule{specialist_id: specialist1.id, date: date},
          [%{start_time: start_time1, visit_type: :ONLINE}],
          []
        )

      {:ok, _day_schedule} =
        DaySchedule.insert_or_update(
          %DaySchedule{specialist_id: specialist2.id, date: date},
          [%{start_time: start_time2, visit_type: :ONLINE}],
          []
        )

      # Check
      {:ok, specialist_ids} =
        MonthSchedule.fetch_specialists_with_timeslots_setup_for_future(
          medical_category.id,
          DateTime.utc_now()
        )

      assert specialist1.id in specialist_ids
      assert specialist2.id in specialist_ids
    end

    test "returns list of specialists with slots already taken in the future" do
      specialist1 = Authentication.Factory.insert(:verified_and_approved_external)
      medical_category = SpecialistProfile.Factory.insert(:medical_category)

      # Setup specialist same medical category
      _ =
        Repo.insert_all("specialists_medical_categories", [
          %{specialist_id: specialist1.id, medical_category_id: medical_category.id}
        ])

      # Setup slots for specialists
      date = ~D[2100-11-15]
      [start_time1] = start_times(date, 1)

      {:ok, _day_schedule} =
        DaySchedule.insert_or_update(
          %DaySchedule{specialist_id: specialist1.id, date: date},
          [%{start_time: start_time1, visit_type: :ONLINE}],
          []
        )

      # Takes one of the visits
      Visits.Commands.TakeTimeslot.call(%Visits.Commands.TakeTimeslot{
        chosen_medical_category_id: medical_category.id,
        patient_id: 1,
        specialist_id: specialist1.id,
        start_time: start_time1,
        visit_type: :ONLINE
      })

      # Check
      {:ok, specialist_ids} =
        MonthSchedule.fetch_specialists_with_timeslots_setup_for_future(
          medical_category.id,
          DateTime.utc_now()
        )

      assert specialist1.id in specialist_ids
    end

    test "returned list consist only of unique specialist ids" do
      specialist1 = Authentication.Factory.insert(:verified_and_approved_external)
      medical_category1 = SpecialistProfile.Factory.insert(:medical_category)
      # Setup specialist medical category

      SpecialistProfile.Specialist.update_categories([medical_category1.id], specialist1.id)

      # Setup slots for specialists
      date = ~D[2100-11-15]
      [start_time1, start_time2] = start_times(date, 2)

      {:ok, _day_schedule} =
        DaySchedule.insert_or_update(
          %DaySchedule{specialist_id: specialist1.id, date: date},
          [
            %{start_time: start_time1, visit_type: :ONLINE},
            %{start_time: start_time2, visit_type: :ONLINE}
          ],
          []
        )

      # Check
      {:ok, specialist_ids} =
        MonthSchedule.fetch_specialists_with_timeslots_setup_for_future(
          medical_category1.id,
          DateTime.utc_now()
        )

      assert length(specialist_ids) == 1
    end

    test "doesn't return specialists without any slots setup in the future" do
      specialist1 = Authentication.Factory.insert(:verified_and_approved_external)
      medical_category1 = SpecialistProfile.Factory.insert(:medical_category)
      # Setup specialist medical category
      _ =
        Repo.insert_all("specialists_medical_categories", [
          %{specialist_id: specialist1.id, medical_category_id: medical_category1.id}
        ])

      # Check
      assert {:ok, []} =
               MonthSchedule.fetch_specialists_with_timeslots_setup_for_future(
                 medical_category1.id,
                 DateTime.utc_now()
               )
    end

    test "returns empty list if there are no specialists for given category" do
      # Check
      assert {:ok, []} =
               MonthSchedule.fetch_specialists_with_timeslots_setup_for_future(
                 1,
                 DateTime.utc_now()
               )
    end
  end

  describe "fetch_specialist_timeslots_setup_for_future_without_today/2" do
    setup do
      %{specialist: Authentication.Factory.insert(:verified_and_approved_external)}
    end

    test "returns empty array if last visit was today", %{specialist: specialist} do
      # Setup slots for specialists
      date = Timex.now()

      {:ok, _day_schedule} =
        Visits.DaySchedule.insert_or_update(
          %Visits.DaySchedule{specialist_id: specialist.id, date: date},
          [],
          [
            %{
              id: UUID.uuid4(),
              start_time: date |> Timex.shift(minutes: -1) |> Timex.to_unix(),
              patient_id: 2,
              record_id: 2,
              visit_id: "2",
              visit_type: :ONLINE
            }
          ]
        )

      assert {:ok, []} =
               MonthSchedule.fetch_specialist_timeslots_setup_for_future_without_today(
                 specialist.id,
                 date
               )
    end

    test "returns specialist_id if specialist still has a visit available today", %{
      specialist: specialist
    } do
      # Setup slots for specialists
      date = Timex.now()

      {:ok, _day_schedule} =
        Visits.DaySchedule.insert_or_update(
          %Visits.DaySchedule{specialist_id: specialist.id, date: date},
          [
            %{start_time: date |> Timex.shift(minutes: 1) |> Timex.to_unix(), visit_type: :ONLINE}
          ],
          [
            %{
              id: UUID.uuid4(),
              start_time: date |> Timex.shift(minutes: -1) |> Timex.to_unix(),
              patient_id: 2,
              record_id: 2,
              visit_id: "2",
              visit_type: :ONLINE
            }
          ]
        )

      assert {:ok, [_specialist_id]} =
               MonthSchedule.fetch_specialist_timeslots_setup_for_future_without_today(
                 specialist.id,
                 date
               )
    end

    test "returns specialist_id if specialist has a visit available tomorrow", %{
      specialist: specialist
    } do
      # Setup slots for specialists
      date = Timex.now()

      {:ok, _day_schedule} =
        Visits.DaySchedule.insert_or_update(
          %Visits.DaySchedule{specialist_id: specialist.id, date: date},
          [],
          [
            %{
              id: UUID.uuid4(),
              start_time: date |> Timex.shift(minutes: -1) |> Timex.to_unix(),
              patient_id: 2,
              record_id: 2,
              visit_id: "2",
              visit_type: :ONLINE
            }
          ]
        )

      date_tomorrow = Timex.shift(date, days: 1)

      {:ok, _day_schedule} =
        Visits.DaySchedule.insert_or_update(
          %Visits.DaySchedule{specialist_id: specialist.id, date: date_tomorrow},
          [%{start_time: Timex.to_unix(date_tomorrow), visit_type: :ONLINE}],
          []
        )

      assert {:ok, [_specialist_id]} =
               MonthSchedule.fetch_specialist_timeslots_setup_for_future_without_today(
                 specialist.id,
                 date
               )
    end

    test "returns empty list if specialist has a visit booked for tomorrow", %{
      specialist: specialist
    } do
      # Setup slots for specialists
      date = Timex.now()
      tomorrow = Timex.shift(date, days: 1)

      {:ok, _day_schedule} =
        Visits.DaySchedule.insert_or_update(
          %Visits.DaySchedule{specialist_id: specialist.id, date: tomorrow},
          [],
          [
            %{
              id: UUID.uuid4(),
              start_time: Timex.to_unix(tomorrow),
              patient_id: 2,
              record_id: 2,
              visit_id: "2",
              visit_type: :ONLINE
            }
          ]
        )

      assert {:ok, [_specialist_id]} =
               MonthSchedule.fetch_specialist_timeslots_setup_for_future_without_today(
                 specialist.id,
                 date
               )
    end
  end

  describe "fetch_specialist_timeslots_setup_for_future/2" do
    setup do
      specialist = Authentication.Factory.insert(:verified_and_approved_external)
      medical_category = SpecialistProfile.Factory.insert(:medical_category)

      SpecialistProfile.update_medical_categories([medical_category.id], specialist.id)

      {:ok, specialist_id: specialist.id, medical_category_id: medical_category.id}
    end

    test "returns list of timeslots setup for future by specialist both free and taken" do
      specialist = Authentication.Factory.insert(:verified_and_approved_external)

      # Setup slots for specialists
      date = ~D[2100-11-15]
      [start_time1, start_time2] = start_times(date, 2)

      {:ok, _day_schedule} =
        DaySchedule.insert_or_update(
          %DaySchedule{specialist_id: specialist.id, date: date},
          [
            %{start_time: start_time1, visit_type: :ONLINE},
            %{start_time: start_time2, visit_type: :ONLINE}
          ],
          []
        )

      # Takes one of the visits
      Visits.Commands.TakeTimeslot.call(%Visits.Commands.TakeTimeslot{
        chosen_medical_category_id: 1,
        patient_id: 1,
        specialist_id: specialist.id,
        start_time: start_time1,
        visit_type: :ONLINE
      })

      # Check
      assert {:ok, timeslots} =
               MonthSchedule.fetch_specialist_timeslots_setup_for_future(
                 specialist.id,
                 DateTime.utc_now()
               )

      assert length(timeslots) == 2
    end

    test "returns empty list if there are no slots setup towards future from date" do
      assert {:ok, []} =
               MonthSchedule.fetch_specialist_timeslots_setup_for_future(1, DateTime.utc_now())
    end

    test "returns empty list if visit was today", %{
      specialist_id: specialist_id
    } do
      # Setup slots for specialists
      date = Timex.now()
      date_taken = Timex.shift(date, minutes: -1)

      {:ok, _day_schedule} =
        DaySchedule.insert_or_update(
          %Visits.DaySchedule{specialist_id: specialist_id, date: date},
          [],
          [
            %{
              id: UUID.uuid4(),
              start_time: Timex.to_unix(date_taken),
              patient_id: 1,
              record_id: 1,
              visit_id: "1",
              visit_type: :ONLINE
            }
          ]
        )

      assert {:ok, []} =
               MonthSchedule.fetch_specialists_with_timeslots_setup_for_future(
                 specialist_id,
                 date
               )
    end
  end
end
