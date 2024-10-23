defmodule Visits.MonthSchedule do
  use Postgres.Service

  alias Visits.DaySchedule

  alias Visits.FreeTimeslot
  alias Visits.TakenTimeslot

  @typep timeslot :: %FreeTimeslot{} | %TakenTimeslot{}

  @doc """
  Returns all timeslots for given specialist

  Range is specified by unix parameter (any unix timestamp which is contained in given month).
  E.g. any value between 1577836800 (2020-01-01T00:00:00) and 1580515199 (2020-01-31T23:59:59)
  will count as January 2020

  Additionally, results will include timeslots from last day of previous and first
  day of following month in order to cover any possible timezone shift.
  E.g. requesting timeslots for January 2020 will return all slots between
  2019-12-31 and 2019-02-01
  """
  @spec fetch_all_timeslots(pos_integer, pos_integer) :: {:ok, [timeslot]}
  def fetch_all_timeslots(specialist_id, unix) do
    {:ok, day_schedules} =
      DaySchedule
      |> where(specialist_id: ^specialist_id)
      |> where([ds], ds.date >= ^day_before_selected_month(unix))
      |> where([ds], ds.date <= ^day_after_selected_month(unix))
      |> order_by(asc: :date)
      |> Repo.fetch_all()

    {:ok, parse_all_timeslots(day_schedules)}
  end

  @doc """
  Returns free timeslots for given specialist

  Rules regarding the range of days are same as for fetch_all_slots/2
  Free slots from the past are filtered out
  """
  @spec fetch_free_timeslots(pos_integer, pos_integer, pos_integer) :: {:ok, [timeslot]}
  def fetch_free_timeslots(specialist_id, unix, patient_id) do
    {:ok, day_schedules} =
      DaySchedule
      |> where(specialist_id: ^specialist_id)
      |> where([ds], ds.date >= ^day_before_selected_month(unix))
      |> where([ds], ds.date <= ^day_after_selected_month(unix))
      |> where([ds], ds.free_timeslots_count > 0)
      |> order_by(asc: :date)
      |> select([:free_timeslots])
      |> Repo.fetch_all()

    {:ok, parse_free_timeslots(day_schedules, patient_id)}
  end

  @doc """
  Returns free timeslots for given medical category
  It considers all of the free timeslots in the future from provided date.
  Free slots from the past are filtered out
  """
  @spec fetch_free_timeslots_for_medical_category(pos_integer, DateTime.t()) ::
          {:ok, [timeslot]}
  def fetch_free_timeslots_for_medical_category(category_id, unix) do
    {:ok, day_schedules} =
      DaySchedule
      |> where([ds], ds.date >= ^unix)
      |> where([ds], ds.free_timeslots_count > 0)
      |> order_by(asc: :date)
      |> join(:inner, [ds], smc in "specialists_medical_categories",
        on: smc.specialist_id == ds.specialist_id
      )
      |> where([ds, smc], smc.medical_category_id == ^category_id)
      |> Repo.fetch_all()

    {:ok, parse_all_timeslots(day_schedules)}
  end

  @doc """
  Returns free timeslots for given medical category

  Rules regarding the range of days are same as for fetch_all_slots/2
  Free slots from the past are filtered out
  """
  @spec fetch_free_timeslots_for_medical_category(pos_integer, pos_integer, pos_integer) ::
          {:ok, [map]}
  def fetch_free_timeslots_for_medical_category(category_id, unix, patient_id) do
    {:ok, day_schedules} =
      DaySchedule
      |> where([ds], ds.date >= ^day_before_selected_month(unix))
      |> where([ds], ds.date <= ^day_after_selected_month(unix))
      |> where([ds], ds.free_timeslots_count > 0)
      |> order_by(asc: :date)
      |> select([:specialist_id, :free_timeslots])
      |> join(:inner, [ds], smc in "specialists_medical_categories",
        on: smc.specialist_id == ds.specialist_id
      )
      |> where([ds, smc], smc.medical_category_id == ^category_id)
      |> Repo.fetch_all()

    {:ok, parse_medical_category_timeslots(day_schedules, patient_id)}
  end

  @doc """
  Returns list of specialists for given medical category with timeslots setup from now.
  It considers both: taken and free slots as long as it's setup in the future.
  """
  @spec fetch_specialists_with_timeslots_setup_for_future(pos_integer, DateTime.t()) ::
          {:ok, [pos_integer]}
  def fetch_specialists_with_timeslots_setup_for_future(category_id, now) do
    {:ok, specialist_ids_with_timeslots} =
      DaySchedule
      |> where([ds], ds.date >= ^now)
      |> where([ds], ds.free_timeslots_count > 0 or ds.taken_timeslots_count > 0)
      |> select([ds], %{
        specialist_id: ds.specialist_id,
        taken_timeslots: ds.taken_timeslots,
        free_timeslots: ds.free_timeslots
      })
      |> join(:inner, [ds], smc in "specialists_medical_categories",
        on: smc.specialist_id == ds.specialist_id
      )
      |> where([ds, smc], smc.medical_category_id == ^category_id)
      |> Repo.fetch_all()

    {:ok, parse_timeslot_setup_for_future(specialist_ids_with_timeslots, now)}
  end

  @doc """
  Returns all of the slots for the given specialist towards the future from given date.
  """
  @spec fetch_specialist_timeslots_setup_for_future(pos_integer, DateTime.t()) ::
          {:ok, [timeslot]}
  def fetch_specialist_timeslots_setup_for_future(specialist_id, now) do
    {:ok, day_schedules} =
      Visits.DaySchedule
      |> where([ds], ds.date >= ^now)
      |> where([ds], ds.free_timeslots_count > 0 or ds.taken_timeslots_count > 0)
      |> where([ds], ds.specialist_id == ^specialist_id)
      |> Repo.fetch_all()

    {:ok, parse_all_timeslots(day_schedules)}
  end

  @doc """
  Returns all of the slots for the given specialist towards the future from given date.
  """
  @spec fetch_specialist_timeslots_setup_for_future_without_today(pos_integer, DateTime.t()) ::
          {:ok, [timeslot]}
  def fetch_specialist_timeslots_setup_for_future_without_today(specialist_id, now) do
    {:ok, day_schedules} =
      Visits.DaySchedule
      |> where([ds], ds.date >= ^now)
      |> where([ds], ds.free_timeslots_count > 0 or ds.taken_timeslots_count > 0)
      |> where([ds], ds.specialist_id == ^specialist_id)
      |> Repo.fetch_all()

    {:ok, parse_timeslot_setup_for_future(day_schedules, now)}
  end

  @spec fetch_specialists_free_day_schedules_for_future([pos_integer], DateTime.t()) ::
          {:ok, [timeslot]}
  def fetch_specialists_free_day_schedules_for_future(specialists_ids, utc_now) do
    DaySchedule
    |> where([ds], ds.specialist_id in ^specialists_ids)
    |> where([ds], ds.date >= ^utc_now)
    |> where([ds], ds.free_timeslots_count > 0)
    |> order_by(asc: :date)
    |> select([:id, :free_timeslots, :specialist_id, :free_timeslots_count, :date])
    |> Repo.fetch_all()
  end

  defp day_before_selected_month(unix) do
    unix
    |> Timex.from_unix(:second)
    |> Timex.beginning_of_month()
    |> Timex.shift(days: -1)
    |> Timex.to_date()
  end

  defp day_after_selected_month(unix) do
    unix
    |> Timex.from_unix(:second)
    |> Timex.end_of_month()
    |> Timex.shift(days: 1)
    |> Timex.to_date()
  end

  defp parse_all_timeslots(day_schedules) do
    now = DateTime.utc_now() |> DateTime.to_unix()

    Enum.flat_map(day_schedules, fn day_schedule ->
      day_schedule
      |> Map.take([:free_timeslots, :taken_timeslots])
      |> Map.values()
      |> List.flatten()
      |> Enum.reject(fn
        %Visits.FreeTimeslot{start_time: start_time} -> start_time < now
        %Visits.TakenTimeslot{} -> false
      end)
      |> Enum.sort_by(fn %{start_time: start_time} -> start_time end)
    end)
  end

  defp parse_free_timeslots(day_schedules, patient_id) do
    now = DateTime.utc_now() |> DateTime.to_unix()
    taken_start_times = taken_start_times(patient_id)

    Enum.flat_map(day_schedules, fn day_schedule ->
      day_schedule
      |> Map.get(:free_timeslots)
      |> Enum.reject(&start_time_before_now_or_taken?(&1.start_time, now, taken_start_times))
      |> Enum.sort_by(fn %{start_time: start_time} -> start_time end)
    end)
  end

  defp parse_medical_category_timeslots(day_schedules, patient_id) do
    now = DateTime.utc_now() |> DateTime.to_unix()
    taken_start_times = taken_start_times(patient_id)

    day_schedules
    |> Enum.flat_map(fn day_schedule ->
      specialist_id = day_schedule.specialist_id
      day_schedule.free_timeslots |> Enum.map(&{&1.start_time, specialist_id})
    end)
    |> Enum.reject(fn {start_time, _} ->
      start_time_before_now_or_taken?(start_time, now, taken_start_times)
    end)
    |> Enum.group_by(&elem(&1, 0), &elem(&1, 1))
    |> Enum.map(fn {start_time, specialist_ids} ->
      %{
        start_time: start_time,
        available_specialist_ids: specialist_ids
      }
    end)
    |> Enum.sort_by(& &1.start_time)
  end

  defp parse_timeslot_setup_for_future(specialist_ids_with_timeslots, now) do
    beginning_of_today = Timex.beginning_of_day(now)

    specialist_ids_with_timeslots
    |> Enum.reject(fn
      %{taken_timeslots: taken_timeslots, free_timeslots: free_timeslots} ->
        taken_timeslots_today =
          Enum.reject(
            taken_timeslots,
            &Timex.between?(
              Timex.from_unix(&1.start_time, :second),
              beginning_of_today,
              now
            )
          )

        free_timeslots_today =
          Enum.reject(
            free_timeslots,
            &Timex.between?(
              Timex.from_unix(&1.start_time, :second),
              beginning_of_today,
              now
            )
          )

        Enum.empty?(taken_timeslots_today) and Enum.empty?(free_timeslots_today)
    end)
    |> Enum.map(& &1.specialist_id)
    |> Enum.uniq()
  end

  defp taken_start_times(patient_id) do
    Visits.PendingVisit
    |> where(patient_id: ^patient_id)
    |> select([v], v.start_time)
    |> Repo.all()
  end

  defp start_time_before_now_or_taken?(start_time, now, taken_start_times) do
    start_time < now or Enum.member?(taken_start_times, start_time)
  end
end
