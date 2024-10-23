defmodule Visits.Commands.CreateTimeslots do
  @moduledoc """
  Module used to create new timeslots in specialist's day schedules.
  """

  use Postgres.Service

  alias __MODULE__.TimeslotDetails
  alias Visits.DaySchedule

  @type t :: %__MODULE__{
          specialist_id: pos_integer,
          timeslots_details: [TimeslotDetails.t(), ...]
        }

  @fields [:specialist_id, :timeslots_details]

  @enforce_keys @fields
  defstruct @fields

  @spec call(t) :: :ok | {:error, String.t()}
  def call(%__MODULE__{} = cmd) do
    specialist_id = cmd.specialist_id
    timeslots_details = cmd.timeslots_details
    start_times = Enum.map(timeslots_details, & &1.start_time)

    timeslots_details_per_date = Enum.group_by(timeslots_details, &unix_to_date(&1.start_time))
    dates = Enum.map(timeslots_details_per_date, fn {date, _timeslots_details} -> date end)

    with true <- specialist_completed_onboarding?(specialist_id),
         :ok <- reject_past_timeslots(start_times) do
      _ =
        Repo.transaction(fn ->
          day_schedules = DaySchedule.lock_for_update(specialist_id, dates)
          :ok = create_timeslots(timeslots_details_per_date, day_schedules, specialist_id)
        end)

      :ok = send_notification_to_waiting_patients(specialist_id)

      :ok
    else
      false -> {:error, "You need to complete onboarding."}
      error -> error
    end
  end

  defp specialist_completed_onboarding?(specialist_id) do
    specialist_id
    |> SpecialistProfile.fetch_status()
    |> case do
      {:ok, %{onboarding_completed: true}} -> true
      _ -> false
    end
  end

  defp create_timeslots(timeslots_details_per_date, day_schedules, specialist_id) do
    Enum.each(timeslots_details_per_date, fn {date, timeslot_details} ->
      day_schedule = find_day_schedule(day_schedules, date, specialist_id)

      stored_timeslots = List.flatten([day_schedule.free_timeslots, day_schedule.taken_timeslots])

      stored_visits =
        Enum.map(stored_timeslots, &%{start_time: &1.start_time, visit_type: &1.visit_type})

      timeslots_to_update =
        Enum.filter(timeslot_details, &timeslot_to_update?(&1, stored_visits))

      timeslots_to_leave_unmodified =
        Enum.filter(
          day_schedule.free_timeslots,
          &timeslot_to_leave_unmodified?(&1, timeslots_to_update)
        )

      timeslots_to_insert =
        Enum.filter(timeslot_details, &timeslot_to_insert?(&1, stored_visits))

      case timeslots_to_insert ++ timeslots_to_update do
        [] ->
          :ok

        timeslots_to_upsert ->
          upsert_timeslots_params =
            Enum.map(
              timeslots_to_upsert,
              &%{start_time: &1.start_time, visit_type: &1.visit_type}
            )

          {:ok, _updated_day_schedule} =
            DaySchedule.insert_or_update(
              day_schedule,
              timeslots_to_leave_unmodified ++ upsert_timeslots_params,
              day_schedule.taken_timeslots
            )
      end
    end)
  end

  defp timeslot_to_update?(timeslot, stored_visits) do
    timeslot.start_time in Enum.map(stored_visits, & &1.start_time) and
      %{start_time: timeslot.start_time, visit_type: timeslot.visit_type} not in stored_visits
  end

  defp timeslot_to_insert?(timeslot, stored_visits) do
    timeslot.start_time not in Enum.map(stored_visits, & &1.start_time)
  end

  defp timeslot_to_leave_unmodified?(timeslot, timeslots_to_update) do
    timeslot_to_update_start_times = Enum.map(timeslots_to_update, & &1.start_time)

    timeslot.start_time not in timeslot_to_update_start_times
  end

  defp find_day_schedule(day_schedules, date, specialist_id) do
    Enum.find(
      day_schedules,
      %DaySchedule{specialist_id: specialist_id, date: date},
      &(&1.date == date)
    )
  end

  defp reject_past_timeslots(start_times) do
    now = DateTime.utc_now() |> DateTime.to_unix()

    case Enum.any?(start_times, &in_past?(&1, now)) do
      true ->
        {:error, "Timeslots cannot be created in the past"}

      false ->
        :ok
    end
  end

  defp unix_to_date(unix) do
    unix |> Timex.from_unix(:second) |> Timex.to_date()
  end

  defp in_past?(start_time, now) do
    start_time < now
  end

  defp send_notification_to_waiting_patients(specialist_id) do
    {:ok, medical_categories} = SpecialistProfile.fetch_medical_categories(specialist_id)
    medical_category_ids = medical_categories |> Enum.map(& &1.id)

    {:ok, visit_demands_for_categories} =
      Visits.Demands.fetch_visit_demands_for_categories(medical_category_ids)

    {:ok, visit_demands_for_specialist} =
      Visits.Demands.fetch_visit_demands_for_specialist(specialist_id)

    :ok = send_push_for_categories(visit_demands_for_categories, medical_categories)
    :ok = send_push_for_specialist(visit_demands_for_specialist, specialist_id)

    :ok =
      Visits.Demands.delete_by_ids(
        Enum.map(visit_demands_for_categories, & &1.id) ++
          Enum.map(visit_demands_for_specialist, & &1.id)
      )
  end

  defp send_push_for_categories(visit_demands, medical_categories) do
    visit_demands
    |> Enum.each(fn visit_demand ->
      PushNotifications.Message.send(%PushNotifications.Message.VisitDemandCategoryProvided{
        send_to_patient_id: visit_demand.patient_id,
        medical_category_id: visit_demand.medical_category_id,
        medical_category_name:
          Enum.find(medical_categories, &(&1.id == visit_demand.medical_category_id)).name
      })
    end)
  end

  defp send_push_for_specialist(visit_demands, specialist_id) do
    {:ok, specialist} = SpecialistProfile.fetch_basic_info(specialist_id)

    visit_demands
    |> Enum.each(fn visit_demand ->
      PushNotifications.Message.send(%PushNotifications.Message.VisitDemandSpecialistProvided{
        send_to_patient_id: visit_demand.patient_id,
        specialist_id: specialist_id,
        specialist_name: "#{specialist.first_name} #{specialist.last_name}"
      })
    end)
  end
end
