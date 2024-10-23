defmodule Membership do
  defdelegate cancel_subscription(specialist_id),
    to: Membership.Subscription.Cancel,
    as: :call

  defdelegate create_subscription(specialist_id, type),
    to: Membership.Subscription.Create,
    as: :call

  defdelegate fetch_subscription(specialist_id),
    to: Membership.Specialists.Subscription,
    as: :fetch

  defdelegate fetch_packages(),
    to: Membership.Packages,
    as: :fetch_all

  defdelegate fetch_package(type),
    to: Membership.Packages,
    as: :fetch_one

  defdelegate fetch_pending_subscription(specialist_id),
    to: Membership.Specialists.Subscription,
    as: :fetch_pending

  defdelegate verify_subscription(specialist_id, order_id),
    to: Membership.Subscription.Verify,
    as: :call
end
