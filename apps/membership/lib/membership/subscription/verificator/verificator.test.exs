defmodule Membership.Subscription.VerificatorTest do
  use Postgres.DataCase, async: true

  import Mockery

  alias Membership.Telr

  describe "verify_pending" do
    test "handle pending subscriptions which weren't checked in defined period of time" do
      checked_long_time_ago = Timex.now() |> Timex.shift(months: -1)

      specialist = Authentication.Factory.insert(:specialist, type: "EXTERNAL")

      pending_subscription =
        Membership.Factory.insert(:pending_subscription, %{
          checked_at: checked_long_time_ago,
          specialist_id: specialist.id
        })

      specialist2 = Authentication.Factory.insert(:specialist, type: "EXTERNAL")

      pending_subscription2 =
        Membership.Factory.insert(:pending_subscription, %{
          checked_at: checked_long_time_ago,
          specialist_id: specialist2.id
        })

      mock(Telr.Gateway, :send, Telr.GatewayFixtures.check_paid())

      assert :ok = Membership.Subscription.Verificator.verify_pending()

      assert {:ok, subscription} = Membership.Subscription.fetch_by_id(pending_subscription.id)
      assert subscription.status == "ACCEPTED"

      assert {:ok, subscription} = Membership.Subscription.fetch_by_id(pending_subscription2.id)
      assert subscription.status == "ACCEPTED"
    end
  end
end
