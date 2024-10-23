defmodule Membership.Subscription.Cancel do
  import Mockery.Macro

  alias Membership.Specialists
  alias Membership.Subscription
  alias Membership.Telr

  @spec call(pos_integer) :: :ok | {:error, :not_found}
  def call(specialist_id) do
    with :ok <- cancel_active(specialist_id) do
      cancel_accepted(specialist_id)
    end
  end

  defp cancel_active(specialist_id) do
    with {:ok, active_subscription} <- Specialists.Subscription.fetch_active(specialist_id) do
      cancel_subscription(active_subscription)
    end
  end

  defp cancel_accepted(specialist_id) do
    with {:ok, accepted_subscription} <- Specialists.Subscription.fetch_accepted(specialist_id) do
      cancel_subscription(accepted_subscription)
    else
      {:error, :not_found} -> :ok
    end
  end

  defp cancel_subscription(subscription) do
    {:ok, _response} =
      mockable(Telr.Tools, by: Telr.ToolsMock).cancel_agreement(subscription.agreement_id)

    {:ok, _subscription} =
      Subscription.update(subscription.id, %{
        status: "CANCELLED",
        cancelled_at: Timex.now()
      })

    :ok
  end
end
