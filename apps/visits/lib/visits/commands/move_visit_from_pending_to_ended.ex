defmodule Visits.Commands.MoveVisitFromPendingToEnded do
  use Postgres.Service

  import Mockery.Macro

  alias Visits.EndedVisit
  alias Visits.PendingVisit

  defmacrop channel_broadcast do
    quote do: mockable(ChannelBroadcast, by: ChannelBroadcastMock)
  end

  @spec call(pos_integer) ::
          {:ok, %EndedVisit{}} | {:error, Ecto.Changeset.t()} | {:error, String.t()}
  def call(visit_id) do
    result =
      Repo.transaction(fn ->
        with {:pending_visit, %{} = pending_visit} <-
               {:pending_visit, PendingVisit.get(visit_id)},
             {:ok, ended_visit} <- EndedVisit.create(pending_visit) do
          {:ok, _} = Repo.delete(pending_visit)

          ended_visit
        else
          {:pending_visit, nil} -> Repo.rollback("selected visit is no longer available")
          {:error, %Ecto.Changeset{} = changeset} -> Repo.rollback(changeset)
        end
      end)

    :ok = handle_side_effects(result)

    result
  end

  defp handle_side_effects({:ok, visit}) do
    channel_broadcast().broadcast({:doctor_pending_visits_update, visit.specialist_id})

    :ok
  end

  defp handle_side_effects({:error, _}) do
    :ok
  end
end
