defmodule Visits.Commands.RemoveTimeslotsTest do
  use Postgres.DataCase, async: true

  alias Visits.Commands.RemoveTimeslots
  alias Visits.DaySchedule

  @minutes_in_timeslot 30
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

  defp in_timeslots_list(start_time, timeslots_list) do
    start_time in Enum.map(timeslots_list, & &1.start_time)
  end

  test "allows to remove multiple timeslots at once" do
    date = ~D[2100-11-30]
    [start_time1, start_time2] = start_times(date, 2)

    {:ok, _existing_schedule} =
      DaySchedule.insert_or_update(
        %DaySchedule{specialist_id: 1, date: date},
        [
          %{start_time: start_time1, visit_type: :ONLINE},
          %{start_time: start_time2, visit_type: :IN_OFFICE}
        ],
        []
      )

    cmd = %RemoveTimeslots{
      specialist_id: 1,
      start_times: [start_time1, start_time2]
    }

    assert :ok = RemoveTimeslots.call(cmd)

    day_schedule = Repo.get_by(DaySchedule, specialist_id: 1, date: date)

    refute Enum.any?(cmd.start_times, &in_timeslots_list(&1, day_schedule.free_timeslots))
    assert day_schedule.free_timeslots_count == 0
    assert day_schedule.taken_timeslots_count == 0
  end

  test "allows to remove multiple timeslots in different days (timezone support)" do
    date1 = ~D[2100-11-29]
    date2 = ~D[2100-11-30]

    [start_time2] = start_times(date2, 1)
    start_time1 = start_time2 - @seconds_in_timeslot

    {:ok, _existing_schedule1} =
      DaySchedule.insert_or_update(
        %DaySchedule{specialist_id: 1, date: date1},
        [%{start_time: start_time1, visit_type: :ONLINE}],
        []
      )

    {:ok, _existing_schedule2} =
      DaySchedule.insert_or_update(
        %DaySchedule{specialist_id: 1, date: date2},
        [%{start_time: start_time2, visit_type: :IN_OFFICE}],
        []
      )

    cmd = %RemoveTimeslots{
      specialist_id: 1,
      start_times: [start_time1, start_time2]
    }

    assert :ok = RemoveTimeslots.call(cmd)

    day_schedule1 = Repo.get_by(DaySchedule, specialist_id: 1, date: date1)
    day_schedule2 = Repo.get_by(DaySchedule, specialist_id: 1, date: date2)

    refute in_timeslots_list(start_time1, day_schedule1.free_timeslots)
    refute in_timeslots_list(start_time2, day_schedule2.free_timeslots)
  end

  test "doesn't allow to remove taken timeslot" do
    date = ~D[2100-11-30]
    [start_time] = start_times(date, 1)

    {:ok, _existing_schedule} =
      DaySchedule.insert_or_update(
        %DaySchedule{specialist_id: 1, date: date},
        [],
        [
          %{
            start_time: start_time,
            patient_id: 1,
            record_id: 1,
            visit_id: UUID.uuid4(),
            id: UUID.uuid4(),
            visit_type: :ONLINE
          }
        ]
      )

    cmd = %RemoveTimeslots{
      specialist_id: 1,
      start_times: [start_time]
    }

    assert {:error, error_msg} = RemoveTimeslots.call(cmd)
    assert is_binary(error_msg)
  end

  test "succeeds when timeslot already doesn't exist" do
    date = ~D[2100-11-30]
    [start_time] = start_times(date, 1)

    cmd = %RemoveTimeslots{
      specialist_id: 1,
      start_times: [start_time]
    }

    assert :ok = RemoveTimeslots.call(cmd)
  end
end
