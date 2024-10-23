defmodule Visits.Commands.CheckIfDoctorCanCallPending do
  use Postgres.Service

  alias Visits.PendingVisit

  @minutes_in_timeslot 30
  @seconds_in_minute 60
  @seconds_in_timeslot @minutes_in_timeslot * @seconds_in_minute

  @spec call(pos_integer) ::
          {:ok, %PendingVisit{}} | {:error, Ecto.Changeset.t()} | {:error, String.t()}
  def call(visit_id) do
    result =
      Repo.transaction(fn ->
        with pending_visit <- get_pending_visit(visit_id),
             true <- can_start?(pending_visit.start_time, pending_visit.visit_type) do
          pending_visit
        else
          {:error, message} -> Repo.rollback(message)
        end
      end)

    result
  end

  defp get_pending_visit(visit_id) do
    case PendingVisit.get(visit_id) do
      nil -> {:error, "This action is no longer available"}
      pending_visit -> pending_visit
    end
  end

  defp can_start?(start_time, visit_type) do
    now = DateTime.utc_now() |> DateTime.to_unix()

    visit_type_action_str = visit_type_action_str(visit_type)

    case {before?(now, start_time), after?(now, start_time)} do
      {false, false} -> true
      {true, _} -> {:error, "You have to wait for scheduled time to #{visit_type_action_str}"}
      {_, true} -> {:error, "Time to #{visit_type_action_str} has already passed"}
    end
  end

  defp visit_type_action_str(visit_type) do
    case visit_type do
      :ONLINE -> "make a call"
      :US_BOARD -> "make a call"
      :IN_OFFICE -> "start a visit"
    end
  end

  defp before?(now, start_time) do
    now < start_time
  end

  defp after?(now, start_time) do
    now > start_time + @seconds_in_timeslot
  end
end
