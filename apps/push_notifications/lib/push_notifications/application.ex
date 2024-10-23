defmodule PushNotifications.Application do
  use Application

  def start(_type, _args) do
    children = [
      PushNotifications.APNS.AccessToken,
      PushNotifications.APNS.Client,
      PushNotifications.Firebase.AccessToken
    ]

    opts = [strategy: :one_for_one, name: PushNotifications.Supervisor]

    Supervisor.start_link(children, opts)
  end
end
