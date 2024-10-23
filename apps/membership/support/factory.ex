defmodule Membership.Factory do
  defp random_string, do: System.unique_integer() |> to_string()

  defp subscription_default_params do
    %{
      type: "PLATINUM",
      order_id: UUID.uuid4(:hex),
      next_payment_date: Timex.now() |> Timex.shift(months: 1),
      ref: random_string(),
      webview_url: random_string()
    }
  end

  defp pending_subscription_default_params do
    Map.merge(subscription_default_params(), %{
      status: "PENDING",
      checked_at: Timex.now()
    })
  end

  defp accepted_subscription_default_params do
    Map.merge(subscription_default_params(), %{
      agreement_id: random_string(),
      status: "ACCEPTED",
      accepted_at: Timex.now(),
      day: Timex.today() |> Timex.day(),
      checked_at: Timex.now(),
      last_payment_at: Timex.now()
    })
  end

  def insert(kind, params \\ %{})

  def insert(:subscription, params) do
    params =
      Map.merge(
        subscription_default_params(),
        Enum.into(params, %{specialist_id: params[:specialist_id]})
      )

    {:ok, subscription} = Membership.Subscription.create(params)

    subscription
  end

  def insert(:pending_subscription, params) do
    params =
      Map.merge(
        pending_subscription_default_params(),
        Enum.into(params, %{specialist_id: params[:specialist_id]})
      )

    subscription = insert(:subscription, params)
    {:ok, subscription} = Membership.Subscription.update(subscription.id, params)

    subscription
  end

  def insert(:accepted_subscription, params) do
    params =
      Map.merge(
        accepted_subscription_default_params(),
        Enum.into(params, %{specialist_id: params[:specialist_id]})
      )

    subscription = insert(:subscription, params)
    {:ok, subscription} = Membership.Subscription.update(subscription.id, params)

    subscription
  end
end
