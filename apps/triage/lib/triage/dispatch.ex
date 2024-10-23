defmodule Triage.Dispatch do
  @moduledoc """
  Functions shared between dispatches of all kinds
  """

  use Postgres.Service

  @spec fetch_by_request_id(String.t()) ::
          {:ok, %Triage.CurrentDispatch{}}
          | {:ok, %Triage.EndedDispatch{}}
          | {:error, :not_found}
  def fetch_by_request_id(request_id) do
    with {:error, :not_found} <- Triage.CurrentDispatch.fetch_by_request_id(request_id),
         {:error, :not_found} <- Triage.EndedDispatch.fetch_by_request_id(request_id) do
      {:error, :not_found}
    else
      {:ok, %struct{} = dispatch} when struct in [Triage.CurrentDispatch, Triage.EndedDispatch] ->
        {:ok, dispatch}
    end
  end
end
