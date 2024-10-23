defmodule Membership.Subscription.CancelTest do
  use Postgres.DataCase, async: true

  import Mockery.Assertions

  describe "call/1" do
    test "should return :ok and set status of active and accepted subscriptions to CANCELLED" do
      specialist = Authentication.Factory.insert(:specialist, type: "EXTERNAL")

      active_subscription =
        Membership.Factory.insert(:accepted_subscription, specialist_id: specialist.id)

      accepted_subscription =
        Membership.Factory.insert(:accepted_subscription, specialist_id: specialist.id)

      assert :ok = Membership.Subscription.Cancel.call(specialist.id)

      {:ok, subscription} = Membership.Subscription.fetch_by_id(active_subscription.id)
      assert subscription.status == "CANCELLED"
      active_agreement_id = active_subscription.agreement_id
      assert_called(Membership.Telr.Tools, :cancel_agreement, [^active_agreement_id])

      {:ok, subscription} = Membership.Subscription.fetch_by_id(accepted_subscription.id)
      assert subscription.status == "CANCELLED"
      accepted_agreement_id = accepted_subscription.agreement_id
      assert_called(Membership.Telr.Tools, :cancel_agreement, [^accepted_agreement_id])
    end

    test "should return {:error, :not_found} where there is no active subscription for given specialist" do
      specialist = Authentication.Factory.insert(:specialist, type: "EXTERNAL")

      assert {:error, :not_found} = Membership.Subscription.Cancel.call(specialist.id)
    end
  end
end
