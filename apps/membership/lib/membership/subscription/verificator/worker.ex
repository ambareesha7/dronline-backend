defmodule Membership.Subscription.Verificator.Worker do
  use GenServer

  alias Membership.Subscription.Verificator

  @interval 60 * 1_000

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_) do
    {:ok, [], {:continue, :after_init}}
  end

  @impl true
  def handle_continue(:after_init, old_state) do
    send(self(), :verify_pending)

    {:noreply, old_state}
  end

  @impl true
  def handle_info(:verify_pending, old_state) do
    Process.send_after(self(), :verify_pending, @interval)

    :ok = Verificator.verify_pending()

    {:noreply, old_state}
  end
end
