defmodule Visits.USBoard.SecondOpinionRequestFSM do
  @doc """
  Finite State Machine implementation for second opinion requests. All status changes and possible transitions are defined in this module
  """

  alias Postgres.Repo
  alias Visits.USBoard.SecondOpinionRequest

  def change_status(request_id, new_status) do
    %{status: current_status} = request = Repo.get(SecondOpinionRequest, request_id)

    if transition_possible?(current_status, new_status) do
      request
      |> SecondOpinionRequest.changeset(%{status: new_status})
      |> Repo.update()
    else
      {:error, :wrong_status_transition}
    end
  end

  defp transition_possible?(:requested, :assigned), do: true
  defp transition_possible?(:assigned, :assigned), do: true
  defp transition_possible?(:assigned, :in_progress), do: true
  defp transition_possible?(:assigned, :rejected), do: true
  defp transition_possible?(:rejected, :assigned), do: true
  defp transition_possible?(:in_progress, :assigned), do: true
  defp transition_possible?(:in_progress, :opinion_submitted), do: true
  defp transition_possible?(:opinion_submitted, :call_scheduled), do: true
  defp transition_possible?(:call_scheduled, :done), do: true
  defp transition_possible?(:done, :cancelled), do: false
  defp transition_possible?(:landing_payment_pending, :landing_booking), do: true
  defp transition_possible?(_current_status, :cancelled), do: true
  defp transition_possible?(_current_status, _new_status), do: false
end
