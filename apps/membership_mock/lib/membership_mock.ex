defmodule MembershipMock do
  defdelegate cancel_subscription(specialist_id),
    to: MembershipMock.Subscription,
    as: :cancel

  defdelegate create_subscription(specialist_id, type),
    to: MembershipMock.Subscription,
    as: :create

  defdelegate fetch_subscription(specialist_id),
    to: MembershipMock.Subscription,
    as: :fetch

  defdelegate fetch_pending_subscription(specialist_id),
    to: MembershipMock.Subscription,
    as: :fetch_pending

  defdelegate verify_subscription(specialist_id, order_id),
    to: MembershipMock.Subscription,
    as: :verify
end
