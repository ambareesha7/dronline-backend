defmodule Visits.Commands.TakeTimeslot do
  @moduledoc """
  Patient wants to request timeslot for new visit
  """

  use Postgres.Service

  import Mockery.Macro

  alias Visits.DaySchedule
  alias Visits.PendingVisit

  @type t :: %__MODULE__{
          chosen_medical_category_id: pos_integer,
          patient_id: pos_integer,
          specialist_id: pos_integer,
          start_time: pos_integer,
          visit_type: :ONLINE | :IN_OFFICE | :US_BOARD,
          us_board_request_id: String.t() | nil
        }

  @required_fields [
    :chosen_medical_category_id,
    :patient_id,
    :specialist_id,
    :start_time,
    :visit_type
  ]

  @enforce_keys @required_fields
  defstruct @required_fields ++ [:us_board_request_id]

  defmacrop channel_broadcast do
    quote do: mockable(ChannelBroadcast, by: ChannelBroadcastMock)
  end

  defmacrop notification do
    quote do: mockable(PushNotifications.Message)
  end

  @spec call(t) :: {:ok, %PendingVisit{}} | {:error, String.t()}
  def call(%__MODULE__{} = cmd) do
    patient_id = cmd.patient_id
    specialist_id = cmd.specialist_id
    start_time = cmd.start_time
    visit_type = cmd.visit_type
    us_board_request_id = cmd.us_board_request_id
    team_id = Teams.specialist_team_id(specialist_id)

    date = unix_to_date(start_time)

    result =
      Repo.transaction(fn ->
        with day_schedules <- DaySchedule.lock_for_update(specialist_id, [date]),
             %{} = day_schedule <- find_day_schedule(day_schedules, date),
             %{} = _free_timeslot <-
               find_free_timeslot_by_start_time(day_schedule, start_time),
             %{} = free_timeslot <-
               find_free_timeslot_by_type(day_schedule, start_time, visit_type),
             {:ok, record} <-
               create_patient_record(visit_type, us_board_request_id, patient_id, specialist_id) do
          {:ok, visit} =
            PendingVisit.create(%{
              id: UUID.uuid4(),
              start_time: start_time,
              patient_id: patient_id,
              record_id: record.id,
              specialist_id: specialist_id,
              visit_type: visit_type,
              chosen_medical_category_id: cmd.chosen_medical_category_id,
              team_id: team_id
            })

          taken_timeslot = %{
            id: free_timeslot.id,
            start_time: free_timeslot.start_time,
            patient_id: patient_id,
            record_id: record.id,
            visit_id: visit.id,
            visit_type: visit_type
          }

          {:ok, _updated_day_schedule} =
            DaySchedule.insert_or_update(
              day_schedule,
              day_schedule.free_timeslots -- [free_timeslot],
              day_schedule.taken_timeslots ++ [taken_timeslot]
            )

          visit
        else
          {:error, error} -> Repo.rollback(error)
        end
      end)

    :ok = handle_side_effects(result)

    result
  end

  defp create_patient_record(:ONLINE, nil, patient_id, specialist_id) do
    EMR.create_visit_patient_record(patient_id, specialist_id)
  end

  defp create_patient_record(:IN_OFFICE, nil, patient_id, specialist_id) do
    EMR.create_in_office_patient_record(patient_id, specialist_id)
  end

  defp create_patient_record(:US_BOARD, us_board_request_id, patient_id, specialist_id) do
    case EMR.create_us_board_patient_record(
           patient_id,
           specialist_id,
           us_board_request_id
         ) do
      {:error,
       %{
         changes: %{type: :US_BOARD},
         errors: [
           patient_id:
             {"has already been taken",
              [
                constraint: :unique,
                constraint_name: "unique_status_call_scheduled_second_opinion_index"
              ]}
         ]
       }} ->
        {:error, cant_schedule_twice()}

      {:ok, record} ->
        {:ok, record}
    end
  end

  defp handle_side_effects({:ok, visit}) do
    _ = EMR.register_interaction_between(visit.specialist_id, visit.patient_id)
    _ = channel_broadcast().broadcast(:pending_visits_update)
    _ = channel_broadcast().broadcast({:doctor_pending_visits_update, visit.specialist_id})

    {:ok, basic_info} = PatientProfile.fetch_basic_info(visit.patient_id)

    notification().send(%PushNotifications.Message.VisitHasBeenScheduled{
      patient_id: visit.patient_id,
      patient_first_name: basic_info.first_name,
      patient_last_name: basic_info.last_name,
      record_id: visit.record_id,
      specialist_id: visit.specialist_id,
      visit_start_time: visit.start_time
    })

    :ok
  end

  defp handle_side_effects({:error, _}) do
    :ok
  end

  defp find_day_schedule(day_schedules, date) do
    case Enum.find(day_schedules, &(&1.date == date)) do
      nil -> {:error, no_longer_available()}
      schedule -> schedule
    end
  end

  defp find_free_timeslot_by_start_time(day_schedule, start_time) do
    case Enum.find(day_schedule.free_timeslots, &(&1.start_time == start_time)) do
      nil -> {:error, no_longer_available()}
      timeslot -> timeslot
    end
  end

  defp find_free_timeslot_by_type(day_schedule, start_time, :US_BOARD) do
    case Enum.find(day_schedule.free_timeslots, &(&1.start_time == start_time)) do
      nil -> {:error, incorrect_visit_type()}
      timeslot -> timeslot
    end
  end

  defp find_free_timeslot_by_type(day_schedule, start_time, visit_type) do
    case Enum.find(
           day_schedule.free_timeslots,
           &(&1.start_time == start_time &&
               ((&1.visit_type == :BOTH && (visit_type == :ONLINE || visit_type == :IN_OFFICE)) ||
                  &1.visit_type == visit_type))
         ) do
      nil -> {:error, incorrect_visit_type()}
      timeslot -> timeslot
    end
  end

  defp unix_to_date(unix) do
    unix |> Timex.from_unix(:second) |> Timex.to_date()
  end

  @doc false
  def no_longer_available, do: "selected timeslot is no longer available"

  @doc false
  def incorrect_visit_type, do: "visit in chosen location not available"

  @doc false
  def cant_schedule_twice, do: "cannot schedule two visits for same second opinion"
end
