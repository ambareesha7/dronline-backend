defmodule Membership.Subscription.PaymentHandler do
  @moduledoc """
  This module checks status of due subscriptions.

  Status is gotten from Telr Tools service.

  Not active agreements are marked as CANCELLED.
  For active ones check is made to verify if payment
  has been authorised.
  """

  import Mockery.Macro

  alias Membership.Subscription
  alias Membership.Subscription.Helpers
  alias Membership.Telr

  @active_agreement "1"
  @authorized_payment "7"
  @spec verify_payments() :: :ok
  def verify_payments do
    {:ok, subscrptions} = Subscription.fetch_due_subscriptions()

    check_subscriptions(subscrptions)
  end

  defp check_subscriptions(subscrptions) do
    subscrptions
    |> Enum.each(fn subscription ->
      {:ok, %{"agreement" => %{"status" => status}}} =
        subscription.agreement_id |> mockable(Telr.Tools).get_agreement()

      {:ok, _subscription} = handle_subscription(status, subscription)
      Helpers.send_package_update_notification(subscription.specialist_id)
    end)
  end

  defp handle_subscription(@active_agreement, subscription) do
    {:ok, history} = subscription.agreement_id |> mockable(Telr.Tools).get_agreement_history()

    expected_paycount = subscription.next_payment_count |> to_string()
    events = history["agreement"]["event"]

    events
    |> verify_last_payment(expected_paycount)
    |> prolong_subscription(subscription)
  end

  defp handle_subscription(_not_valid_agreement, subscription) do
    params = %{
      status: "ENDED",
      ended_at: Timex.now()
    }

    Subscription.update(subscription.id, params)
  end

  defp verify_last_payment(events, expected_paycount) do
    Enum.find(events, fn
      %{"paycount" => ^expected_paycount, "type" => @authorized_payment} -> true
      _ -> false
    end)
  end

  defp prolong_subscription(nil, subscription), do: {:ok, subscription}

  defp prolong_subscription(_payment, subscription) do
    params = %{
      last_payment_at: DateTime.utc_now(),
      next_payment_count: subscription.next_payment_count + 1,
      next_payment_date: calculate_next_payment_date(subscription)
    }

    Subscription.update(subscription.id, params)
  end

  defp calculate_next_payment_date(subscription) do
    subscription.next_payment_date
    |> Timex.shift(months: 1)
    |> Timex.set(day: subscription.day)
  end
end
