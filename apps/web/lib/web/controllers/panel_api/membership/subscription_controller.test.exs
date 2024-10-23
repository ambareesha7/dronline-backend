defmodule Web.PanelApi.Membership.SubscriptionControllerTest do
  use Web.ConnCase, async: true

  alias Proto.Membership.GetActivePackageResponse
  alias Proto.Membership.GetPendingSubscriptionResponse
  alias Proto.Membership.SubscribeRequest
  alias Proto.Membership.SubscribeResponse
  alias Proto.Membership.VerifyRequest
  alias Proto.Membership.VerifyResponse

  @moduletag :skip

  describe "GET pending_subscription" do
    setup [:proto_content, :authenticate_external]

    test "success", %{conn: conn, current_external: current_external} do
      SpecialistProfile.Factory.insert(:location, specialist_id: current_external.id)
      SpecialistProfile.Factory.insert(:basic_info, specialist_id: current_external.id)

      pending_subscription =
        Membership.Factory.insert(:pending_subscription, specialist_id: current_external.id)

      conn = get(conn, panel_membership_subscription_path(conn, :pending_subscription))

      assert %GetPendingSubscriptionResponse{redirect_url: redirect_url} =
               proto_response(conn, 200, GetPendingSubscriptionResponse)

      assert redirect_url == pending_subscription.webview_url
    end
  end

  describe "GET show" do
    setup [:authenticate_external]

    test "returns active package", %{conn: conn, current_external: current_external} do
      _ =
        Membership.Factory.insert(:accepted_subscription,
          specialist_id: current_external.id,
          type: "PLATINUM"
        )

      conn = get(conn, panel_membership_subscription_path(conn, :show))

      assert %GetActivePackageResponse{
               active_package: %{},
               expires_at: %{timestamp: _timestamp},
               next_package: nil
             } = proto_response(conn, 200, GetActivePackageResponse)
    end
  end

  describe "POST subscribe" do
    setup [:proto_content, :authenticate_external]

    test "success", %{conn: conn, current_external: current_external} do
      SpecialistProfile.Factory.insert(:location, specialist_id: current_external.id)
      SpecialistProfile.Factory.insert(:basic_info, specialist_id: current_external.id)

      proto =
        %{
          type: "PLATINUM"
        }
        |> SubscribeRequest.new()
        |> SubscribeRequest.encode()

      conn = post(conn, panel_membership_subscription_path(conn, :subscribe), proto)

      assert %SubscribeResponse{redirect_url: redirect_url} =
               proto_response(conn, 200, SubscribeResponse)

      assert is_binary(redirect_url)
    end
  end

  describe "POST verify" do
    setup [:proto_content, :authenticate_external]

    test "success", %{conn: conn, current_external: current_external} do
      subscription =
        Membership.Factory.insert(:pending_subscription, specialist_id: current_external.id)

      proto =
        %{
          order_id: subscription.order_id
        }
        |> VerifyRequest.new()
        |> VerifyRequest.encode()

      conn = post(conn, panel_membership_subscription_path(conn, :verify), proto)

      expected_status = VerifyResponse.Status.value(:PAID)
      assert %VerifyResponse{status: ^expected_status} = proto_response(conn, 200, VerifyResponse)
    end
  end

  describe "POST cancel" do
    setup [:authenticate_external]

    test "success", %{conn: conn, current_external: current_external} do
      _subscription =
        Membership.Factory.insert(:accepted_subscription, specialist_id: current_external.id)

      conn = post(conn, panel_membership_subscription_path(conn, :cancel))

      assert response(conn, 204)
    end
  end
end
