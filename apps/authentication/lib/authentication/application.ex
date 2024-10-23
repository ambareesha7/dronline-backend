defmodule Authentication.Application do
  use Application

  def start(_type, _args) do
    children = [
      {Task.Supervisor, name: Authentication.TaskSupervisor}
    ]

    opts = [strategy: :one_for_one, name: Authentication.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
