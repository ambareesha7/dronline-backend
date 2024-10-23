defmodule Membership.Subscription.Verificator do
  alias Membership.Subscription

  @spec verify_pending() :: :ok
  def verify_pending do
    with {:ok, subscriptions} <- Subscription.get_pending_to_verify(),
         :ok <- verify_subscriptions(subscriptions) do
      :ok
    end
  end

  defp verify_subscriptions([]), do: :ok

  defp verify_subscriptions(subscriptions) do
    subscriptions
    |> Enum.each(&Subscription.Verify.call/1)
  end
end
