defmodule Membership.Subscription.PaymentHandler.Worker do
  use GenServer

  alias Membership.Subscription.PaymentHandler

  @env Mix.env()
  @interval 60 * 60 * 1_000

  def start_link(_) do
    GenServer.start_link(__MODULE__, @env, name: __MODULE__)
  end

  @impl true
  def init(_) do
    {:ok, %{}, {:continue, :after_init}}
  end

  @impl true
  def handle_continue(:after_init, old_state) do
    send(self(), :verify_payments)

    {:noreply, old_state}
  end

  @impl true
  def handle_info(:verify_payments, old_state) do
    Process.send_after(self(), :verify_payments, @interval)

    :ok = PaymentHandler.verify_payments()

    {:noreply, old_state}
  end
end
