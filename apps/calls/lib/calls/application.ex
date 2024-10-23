defmodule Calls.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      Calls.CallSupervisor
    ]

    opts = [
      # Don't allow crashes from this supervisor to propagate higher
      max_restarts: 1_000_000,
      max_seconds: 1,
      name: Calls.Supervisor,
      strategy: :one_for_one
    ]

    Supervisor.start_link(children, opts)
  end
end
