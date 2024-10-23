defmodule EMR.Application do
  use Application

  require Logger

  def start(_type, _args) do
    children = []

    Supervisor.start_link(children, strategy: :one_for_one, name: EMR.Supervisor)
  end
end
