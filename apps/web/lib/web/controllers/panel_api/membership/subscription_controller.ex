defmodule Web.PanelApi.Membership.SubscriptionController do
  use Conductor
  use Web, :controller

  action_fallback Web.FallbackController

  @authorize scopes: ["EXTERNAL", "EXTERNAL_REJECTED"]
  def pending_subscription(conn, _params) do
    specialist_id = conn.assigns.current_specialist_id

    with {:ok, pending_subscription} <- fetch_pending_subscription(specialist_id) do
      render(conn, "pending_subscription.proto", %{pending_subscription: pending_subscription})
    end
  end

  @authorize scopes: ["EXTERNAL", "EXTERNAL_REJECTED"]
  def show(conn, _params) do
    specialist_id = conn.assigns.current_specialist_id

    with {:ok, active_package, expires_at, next_package} <-
           fetch_subscription(specialist_id) do
      render(conn, "show.proto", %{
        active_package: active_package,
        expires_at: expires_at,
        next_package: next_package
      })
    end
  end

  @authorize scopes: ["EXTERNAL", "EXTERNAL_REJECTED"]
  @decode Proto.Membership.SubscribeRequest
  def subscribe(conn, _params) do
    proto = conn.assigns.protobuf
    specialist_id = conn.assigns.current_specialist_id

    with {:ok, redirect_url} <- create_subscription(specialist_id, proto.type) do
      render(conn, "subscribe.proto", %{redirect_url: redirect_url})
    end
  end

  @authorize scopes: ["EXTERNAL", "EXTERNAL_REJECTED"]
  @decode Proto.Membership.VerifyRequest
  def verify(conn, _params) do
    proto = conn.assigns.protobuf
    specialist_id = conn.assigns.current_specialist_id

    with {:ok, status} <- verify_subscription(specialist_id, proto.order_id) do
      render(conn, "verify.proto", %{status: status})
    end
  end

  @authorize scopes: ["EXTERNAL", "EXTERNAL_REJECTED"]
  def cancel(conn, _params) do
    specialist_id = conn.assigns.current_specialist_id

    with :ok <- cancel_subscription(specialist_id) do
      send_resp(conn, 204, "")
    end
  end

  defp fetch_pending_subscription(specialist_id) do
    if payments_enabled?(),
      do: Membership.fetch_pending_subscription(specialist_id),
      else: MembershipMock.fetch_pending_subscription(specialist_id)
  end

  defp fetch_subscription(specialist_id) do
    if payments_enabled?(),
      do: Membership.fetch_subscription(specialist_id),
      else: MembershipMock.fetch_subscription(specialist_id)
  end

  defp create_subscription(specialist_id, type) do
    if payments_enabled?(),
      do: Membership.create_subscription(specialist_id, type),
      else: MembershipMock.create_subscription(specialist_id, type)
  end

  defp verify_subscription(specialist_id, order_id) do
    if payments_enabled?(),
      do: Membership.verify_subscription(specialist_id, order_id),
      else: MembershipMock.verify_subscription(specialist_id, order_id)
  end

  defp cancel_subscription(specialist_id) do
    if payments_enabled?(),
      do: Membership.cancel_subscription(specialist_id),
      else: MembershipMock.cancel_subscription(specialist_id)
  end

  defp payments_enabled?, do: FeatureFlags.enabled?("specialist_membership_payments")
end
