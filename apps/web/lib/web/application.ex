defmodule Web.Application do
  use Application

  def start(_type, _args) do
    {:ok, _} = Logger.add_backend(Sentry.LoggerBackend)

    children = [
      Web.Endpoint,
      {Task.Supervisor, [name: Web.TaskSupervisor]},
      Web.ChannelBroadcastWorker,
      {Phoenix.PubSub, name: Web.PubSub},
      {Web.Presence, [pubsub_server: Web.PubSub]}
    ]

    opts = [strategy: :one_for_one, name: Web.Supervisor]

    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Web.Endpoint.config_change(changed, removed)

    :ok
  end
end
