defmodule Membership.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Membership.Subscription.PaymentHandler.Worker,
      # Membership.Subscription.Verificator.Worker
    ]

    opts = [strategy: :one_for_one, name: Membership.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
