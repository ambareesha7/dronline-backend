defmodule Visits.Commands.CreateTimeslotsTest do
  use Postgres.DataCase, async: true

  alias Visits.Commands.CreateTimeslots
  alias Visits.Commands.CreateTimeslots.TimeslotDetails
  alias Visits.DaySchedule

  @minutes_in_timeslot 30
  @seconds_in_minute 60
  @seconds_in_timeslot @minutes_in_timeslot * @seconds_in_minute

  defp timeslots_details(%{start_time: start_time, count: count} = params)
       when is_integer(start_time) do
    for i <- 0..(count - 1) do
      %TimeslotDetails{
        start_time: start_time + i * @seconds_in_timeslot,
        visit_type: Map.get(params, :visit_type, random_visit_type())
      }
    end
  end

  defp timeslots_details(%{start_time: start_time} = params) do
    params
    |> Map.put(:start_time, Timex.to_unix(start_time))
    |> timeslots_details()
  end

  defp random_visit_type, do: Enum.random([:ONLINE, :IN_OFFICE, :US_BOARD, :BOTH])

  defp start_time_in_timeslots_list?(start_time, timeslots_list) do
    start_time in Enum.map(timeslots_list, & &1.start_time)
  end

  defp visit_type_in_timeslots_list?(visit_type, timeslots_list) do
    visit_type in Enum.map(timeslots_list, & &1.visit_type)
  end

  test "allows to create multiple timeslots at once" do
    specialist = Authentication.Factory.insert(:verified_and_approved_external)
    date = ~D[2100-11-30]

    cmd = %CreateTimeslots{
      specialist_id: specialist.id,
      timeslots_details: timeslots_details(%{start_time: date, count: 2})
    }

    assert :ok = CreateTimeslots.call(cmd)

    day_schedule = Repo.get_by(DaySchedule, specialist_id: specialist.id, date: date)

    assert Enum.all?(
             cmd.timeslots_details,
             &start_time_in_timeslots_list?(&1.start_time, day_schedule.free_timeslots)
           )

    assert day_schedule.free_timeslots_count == 2
    assert day_schedule.taken_timeslots_count == 0
  end

  test "allows to change type from both to one" do
    specialist = Authentication.Factory.insert(:verified_and_approved_external)
    date = ~D[2100-11-30]

    assert :ok =
             CreateTimeslots.call(%CreateTimeslots{
               specialist_id: specialist.id,
               timeslots_details:
                 timeslots_details(%{start_time: date, count: 1, visit_type: :BOTH})
             })

    cmd_create_in_office = %CreateTimeslots{
      specialist_id: specialist.id,
      timeslots_details: timeslots_details(%{start_time: date, count: 1, visit_type: :IN_OFFICE})
    }

    assert :ok = CreateTimeslots.call(cmd_create_in_office)

    day_schedule = Repo.get_by(DaySchedule, specialist_id: specialist.id, date: date)

    assert Enum.all?(
             cmd_create_in_office.timeslots_details,
             &start_time_in_timeslots_list?(&1.start_time, day_schedule.free_timeslots)
           )

    assert Enum.all?(
             cmd_create_in_office.timeslots_details,
             &visit_type_in_timeslots_list?(&1.visit_type, day_schedule.free_timeslots)
           )

    assert day_schedule.free_timeslots_count == 1
    assert day_schedule.taken_timeslots_count == 0
  end

  test "deletes visit demands for given specialist and category" do
    specialist = Authentication.Factory.insert(:verified_and_approved_external)
    {:ok, medical_categories} = SpecialistProfile.fetch_medical_categories(specialist.id)
    medical_categories_ids = Enum.map(medical_categories, & &1.id)
    date = ~D[2100-11-30]

    cmd = %CreateTimeslots{
      specialist_id: specialist.id,
      timeslots_details: timeslots_details(%{start_time: date, count: 1})
    }

    # create visit demand for one of the medical categories of the specialist
    {:ok, _} =
      Visits.Demands.create(%{
        patient_id: 1,
        medical_category_id: List.first(medical_categories_ids)
      })

    {:ok, _} =
      Visits.Demands.create(%{
        patient_id: 2,
        specialist_id: specialist.id
      })

    {:ok, visit_demands_for_category} =
      Visits.Demands.fetch_visit_demands_for_categories(medical_categories_ids)

    {:ok, visit_demands_for_specialist} =
      Visits.Demands.fetch_visit_demands_for_specialist(specialist.id)

    assert length(visit_demands_for_category ++ visit_demands_for_specialist) == 2

    assert :ok = CreateTimeslots.call(cmd)

    assert {:ok, []} = Visits.Demands.fetch_visit_demands_for_categories(medical_categories_ids)
    assert {:ok, []} = Visits.Demands.fetch_visit_demands_for_specialist(specialist.id)
  end

  test "allows to create multiple timeslots in different days (timezone support)" do
    specialist = Authentication.Factory.insert(:verified_and_approved_external)
    date1 = ~D[2100-11-29]
    date2 = ~D[2100-11-30]

    start_time2 = Timex.to_unix(date2)
    start_time1 = start_time2 - @seconds_in_timeslot

    cmd = %CreateTimeslots{
      specialist_id: specialist.id,
      timeslots_details: [
        %TimeslotDetails{start_time: start_time1, visit_type: random_visit_type()},
        %TimeslotDetails{start_time: start_time2, visit_type: random_visit_type()}
      ]
    }

    assert :ok = CreateTimeslots.call(cmd)

    day_schedule1 = Repo.get_by(DaySchedule, specialist_id: specialist.id, date: date1)
    day_schedule2 = Repo.get_by(DaySchedule, specialist_id: specialist.id, date: date2)

    assert start_time_in_timeslots_list?(start_time1, day_schedule1.free_timeslots)
    assert start_time_in_timeslots_list?(start_time2, day_schedule2.free_timeslots)
  end

  test "doesn't touch existing timeslots" do
    specialist = Authentication.Factory.insert(:verified_and_approved_external)
    date = ~D[2100-11-30]

    start_time1 = Timex.to_unix(date)
    start_time2 = start_time1 + @seconds_in_timeslot
    start_time3 = start_time2 + @seconds_in_timeslot

    {:ok, _existing_schedule} =
      DaySchedule.insert_or_update(
        %DaySchedule{specialist_id: specialist.id, date: date},
        [%{start_time: start_time1, visit_type: random_visit_type()}],
        [
          %{
            start_time: start_time2,
            patient_id: 1,
            record_id: 1,
            visit_id: UUID.uuid4(),
            id: UUID.uuid4(),
            visit_type: :ONLINE
          }
        ]
      )

    cmd = %CreateTimeslots{
      specialist_id: specialist.id,
      timeslots_details: [
        %TimeslotDetails{start_time: start_time3, visit_type: random_visit_type()}
      ]
    }

    assert :ok = CreateTimeslots.call(cmd)

    day_schedule = Repo.get_by(DaySchedule, specialist_id: specialist.id, date: date)

    assert Enum.all?(
             [start_time1, start_time3],
             &start_time_in_timeslots_list?(&1, day_schedule.free_timeslots)
           )

    assert start_time_in_timeslots_list?(start_time2, day_schedule.taken_timeslots)
    assert day_schedule.free_timeslots_count == 2
    assert day_schedule.taken_timeslots_count == 1
  end

  test "ignores overlapping because mobile adds timeslots by changing range" do
    specialist = Authentication.Factory.insert(:verified_and_approved_external)
    date = ~D[2100-11-30]

    start_time1 = Timex.to_unix(date)
    start_time2 = start_time1 + @seconds_in_timeslot

    {:ok, _existing_schedule} =
      DaySchedule.insert_or_update(
        %DaySchedule{specialist_id: specialist.id, date: date},
        [],
        [
          %{
            start_time: start_time1,
            patient_id: 1,
            record_id: 1,
            visit_id: UUID.uuid4(),
            id: UUID.uuid4(),
            visit_type: :ONLINE
          }
        ]
      )

    cmd = %CreateTimeslots{
      specialist_id: specialist.id,
      timeslots_details: [
        %TimeslotDetails{start_time: start_time1, visit_type: :ONLINE},
        %TimeslotDetails{start_time: start_time2, visit_type: :ONLINE}
      ]
    }

    assert :ok = CreateTimeslots.call(cmd)

    day_schedule = Repo.get_by(DaySchedule, specialist_id: specialist.id, date: date)

    assert start_time_in_timeslots_list?(start_time1, day_schedule.taken_timeslots)
    assert start_time_in_timeslots_list?(start_time2, day_schedule.free_timeslots)
    assert day_schedule.free_timeslots_count == 1
    assert day_schedule.taken_timeslots_count == 1
  end

  test "errors on start_times in the past" do
    specialist = Authentication.Factory.insert(:verified_and_approved_external)
    date = ~D[1992-11-30]

    cmd = %CreateTimeslots{
      specialist_id: specialist.id,
      timeslots_details: timeslots_details(%{start_time: date, count: 1})
    }

    assert {:error, error_msg} = CreateTimeslots.call(cmd)
    assert is_binary(error_msg)
  end

  test "errors on specialist without completed onboarding" do
    date = ~D[1992-11-30]

    cmd = %CreateTimeslots{
      specialist_id: 1,
      timeslots_details: timeslots_details(%{start_time: date, count: 1})
    }

    assert {:error, error_msg} = CreateTimeslots.call(cmd)
    assert is_binary(error_msg)
  end
end
