defmodule Mailers.Application do
  use Application

  require Logger

  def start(_type, _args) do
    children = [
      {Oban, oban_config()}
    ]

    opts = [
      # Don't allow crashes from this supervisor to propagate higher
      max_restarts: 1_000_000,
      max_seconds: 1,
      name: Mailers.Supervisor,
      strategy: :one_for_one
    ]

    Supervisor.start_link(children, opts)
  end

  defp oban_config do
    Application.fetch_env!(:oban, Oban)
  end
end
