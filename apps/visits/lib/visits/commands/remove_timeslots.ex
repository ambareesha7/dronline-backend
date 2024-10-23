defmodule Visits.Commands.RemoveTimeslots do
  @moduledoc """
  Specialist wants to remove his free timeslots
  """

  use Postgres.Service

  alias Visits.DaySchedule

  @type t :: %__MODULE__{
          specialist_id: pos_integer,
          start_times: [pos_integer, ...]
        }

  @fields [:specialist_id, :start_times]

  @enforce_keys @fields
  defstruct @fields

  @spec call(t) :: :ok | {:error, String.t()}
  def call(%__MODULE__{} = cmd) do
    specialist_id = cmd.specialist_id
    start_times = cmd.start_times

    start_times_per_date = Enum.group_by(start_times, &unix_to_date/1)
    dates = Enum.map(start_times_per_date, fn {date, _start_times} -> date end)

    transaction_result =
      Repo.transaction(fn ->
        with day_schedules <- DaySchedule.lock_for_update(specialist_id, dates),
             :ok <- remove_timeslots(start_times_per_date, day_schedules, specialist_id) do
          :ok
        else
          {:error, reason} ->
            Repo.rollback(reason)
        end
      end)

    case transaction_result do
      {:ok, _} -> :ok
      {:error, reason} -> {:error, reason}
    end
  end

  defp remove_timeslots(start_times_per_date, day_schedules, _specialist_id) do
    Enum.reduce_while(start_times_per_date, :ok, fn {date, provided_start_times}, _acc ->
      with {:find_day_schedule, %{} = day_schedule} <-
             {:find_day_schedule, find_day_schedule(day_schedules, date)},
           {:check_taken_timeslots, :ok} <-
             {:check_taken_timeslots, check_taken_timeslots(day_schedule, provided_start_times)} do
        timeslots_to_be_removed =
          Enum.filter(day_schedule.free_timeslots, &(&1.start_time in provided_start_times))

        {:ok, _updated_day_schedule} =
          DaySchedule.insert_or_update(
            day_schedule,
            day_schedule.free_timeslots -- timeslots_to_be_removed,
            day_schedule.taken_timeslots
          )

        {:cont, :ok}
      else
        {:find_day_schedule, nil} ->
          {:cont, :ok}

        {:check_taken_timeslots, error} ->
          {:halt, error}
      end
    end)
  end

  defp find_day_schedule(day_schedules, date) do
    Enum.find(day_schedules, &(&1.date == date))
  end

  defp check_taken_timeslots(day_schedule, provided_start_times) do
    taken_start_times = Enum.map(day_schedule.taken_timeslots, & &1.start_time)

    case Enum.any?(provided_start_times, &(&1 in taken_start_times)) do
      true ->
        {:error, "one of timeslots cannot be removed"}

      false ->
        :ok
    end
  end

  defp unix_to_date(unix) do
    unix |> Timex.from_unix(:second) |> Timex.to_date()
  end
end
