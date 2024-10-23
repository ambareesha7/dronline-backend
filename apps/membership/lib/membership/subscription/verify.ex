defmodule Membership.Subscription.Verify do
  import Mockery.Macro

  alias Membership.Specialists
  alias Membership.Subscription
  alias Membership.Subscription.Helpers
  alias Membership.Telr

  @pending_code 1
  @authorised_code 2
  @paid_code 3

  @spec call(%Subscription{}) :: {:ok, atom} | {:error, any()}
  def call(subscription) do
    with {:ok, response} <- get_payment_check_response(subscription) do
      handle_response(subscription, response)
    end
  end

  @spec call(non_neg_integer, non_neg_integer) :: {:ok, atom} | {:error, any()}
  def call(specialist_id, order_id) do
    with {:ok, subscription} <-
           Specialists.Subscription.fetch_by_order_id(specialist_id, order_id),
         {:ok, response} <- get_payment_check_response(subscription) do
      handle_response(subscription, response)
    end
  end

  defp get_payment_check_response(subscription) do
    body = Helpers.prepare_check_request_body(subscription)

    mockable(Telr.Gateway, by: Telr.GatewayMock).send(body)
  end

  def handle_response(subscription, response) do
    case get_status(response) do
      :DECLINED ->
        handle_declined_subscription(subscription, response)

      :PAID ->
        handle_accepted_subscription(subscription, response)

      :PENDING ->
        {:ok, :PENDING}
    end
  end

  defp handle_declined_subscription(subscription, response) do
    update_subscription(subscription.id, subscription.specialist_id, response)

    {:ok, :DECLINED}
  end

  defp handle_accepted_subscription(subscription, response) do
    case Specialists.Subscription.fetch_active(subscription.specialist_id) do
      {:ok, active_subscription} ->
        handle_subscription_change(active_subscription, subscription, response)

      {:error, :not_found} ->
        update_subscription(subscription.id, subscription.specialist_id, response)
    end

    {:ok, :PAID}
  end

  defp handle_subscription_change(active_subscription, subscription, response) do
    case Helpers.subscription_action(active_subscription, subscription.type) do
      :upgrade ->
        handle_upgrade(active_subscription, subscription, response)

      :downgrade ->
        handle_downgrade(active_subscription, subscription, response)

      :invalid_action ->
        :ok
    end
  end

  defp handle_upgrade(active_subscription, subscription, response) do
    Helpers.cancel_waiting_subscription(subscription.specialist_id)
    Helpers.end_active_subscription(active_subscription)

    update_subscription(subscription.id, subscription.specialist_id, response)
  end

  defp handle_downgrade(active_subscription, subscription, response) do
    Helpers.cancel_waiting_subscription(subscription.specialist_id)
    Helpers.cancel_active_subscription(active_subscription)

    update_subscription(subscription.id, subscription.specialist_id, response)
  end

  defp get_status(%{"order" => %{"status" => %{"code" => @pending_code}}}), do: :PENDING

  defp get_status(%{"order" => %{"status" => %{"code" => code}}})
       when code in [@authorised_code, @paid_code] do
    :PAID
  end

  defp get_status(_), do: :DECLINED

  defp update_subscription(subscription_id, specialist_id, response) do
    {:ok, update_params} = Helpers.parse_response(response)
    {:ok, _subscription} = Subscription.update(subscription_id, update_params)
    {:ok, _specialist} = Specialists.end_active_trial(specialist_id)

    :ok
  end
end
