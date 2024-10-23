defmodule Postgres.Application do
  use Application

  require Logger

  def start(_type, _args) do
    notifications_config =
      Keyword.put(Postgres.Config.get_repo_config(), :name, Postgres.Notifications)

    children = [
      Postgres.Repo,
      %{
        id: Postgres.Notifications,
        start: {Postgrex.Notifications, :start_link, [notifications_config]}
      }
    ]

    result = Supervisor.start_link(children, strategy: :one_for_one, name: Postgres.Supervisor)

    _ = Postgres.migrate!()

    result
  end
end
