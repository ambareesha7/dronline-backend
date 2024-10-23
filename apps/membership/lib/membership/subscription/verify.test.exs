defmodule Membership.Subscription.VerifyTest do
  use Postgres.DataCase, async: true

  import Mockery

  alias Membership.Specialists.Specialist
  alias Membership.Telr

  describe "call/1" do
    test "success for paid response" do
      specialist = Authentication.Factory.insert(:specialist, type: "EXTERNAL")

      pending_subscription =
        Membership.Factory.insert(:pending_subscription, %{
          specialist_id: specialist.id
        })

      mock(Telr.Gateway, :send, Telr.GatewayFixtures.check_paid())

      assert {:ok, :PAID} = Membership.Subscription.Verify.call(pending_subscription)
      assert {:ok, subscription} = Membership.Subscription.fetch_by_id(pending_subscription.id)
      assert subscription.status == "ACCEPTED"
      refute is_nil(subscription.day)
      refute is_nil(subscription.agreement_id)
      assert subscription.active
      refute is_nil(subscription.accepted_at)

      # End trial
      %{trial_ends_at: trial_ends_at} = Repo.get_by(Specialist, id: specialist.id)
      assert NaiveDateTime.diff(trial_ends_at, NaiveDateTime.utc_now()) == 0
    end

    test "success for pending response" do
      specialist = Authentication.Factory.insert(:specialist, type: "EXTERNAL")

      pending_subscription =
        Membership.Factory.insert(:pending_subscription, %{
          specialist_id: specialist.id
        })

      mock(Telr.Gateway, :send, Telr.GatewayFixtures.check_pending())

      assert {:ok, :PENDING} = Membership.Subscription.Verify.call(pending_subscription)
      assert {:ok, subscription} = Membership.Subscription.fetch_by_id(pending_subscription.id)
      assert subscription.status == "PENDING"

      # Don't end trial
      %{trial_ends_at: trial_ends_at} = Repo.get_by(Specialist, id: specialist.id)
      assert NaiveDateTime.diff(trial_ends_at, NaiveDateTime.utc_now()) > 0
    end

    test "success for authorised response" do
      specialist = Authentication.Factory.insert(:specialist, type: "EXTERNAL")

      pending_subscription =
        Membership.Factory.insert(:pending_subscription, %{
          specialist_id: specialist.id
        })

      mock(Telr.Gateway, :send, Telr.GatewayFixtures.check_authorised())

      assert {:ok, :PAID} = Membership.Subscription.Verify.call(pending_subscription)
      assert {:ok, subscription} = Membership.Subscription.fetch_by_id(pending_subscription.id)
      assert subscription.status == "ACCEPTED"
      refute is_nil(subscription.day)
      refute is_nil(subscription.agreement_id)
    end

    test "success for declined response" do
      specialist = Authentication.Factory.insert(:specialist, type: "EXTERNAL")

      pending_subscription =
        Membership.Factory.insert(:pending_subscription, %{
          specialist_id: specialist.id
        })

      mock(Telr.Gateway, :send, Telr.GatewayFixtures.check_declined())

      assert {:ok, :DECLINED} = Membership.Subscription.Verify.call(pending_subscription)
      assert {:ok, subscription} = Membership.Subscription.fetch_by_id(pending_subscription.id)
      assert subscription.status == "DECLINED"
      refute is_nil(subscription.declined_at)
    end

    test "success for upgrade" do
      specialist = Authentication.Factory.insert(:specialist, type: "EXTERNAL")

      active_subscription =
        Membership.Factory.insert(:accepted_subscription, %{
          specialist_id: specialist.id,
          type: "GOLD"
        })

      silver_subscription =
        Membership.Factory.insert(:accepted_subscription, %{
          specialist_id: specialist.id,
          type: "SILVER"
        })

      pending_subscription =
        Membership.Factory.insert(:pending_subscription, %{
          specialist_id: specialist.id,
          type: "PLATINUM"
        })

      mock(Telr.Gateway, :send, Telr.GatewayFixtures.check_authorised())

      assert {:ok, :PAID} = Membership.Subscription.Verify.call(pending_subscription)
      assert {:ok, subscription} = Membership.Subscription.fetch_by_id(pending_subscription.id)
      assert subscription.status == "ACCEPTED"
      refute is_nil(subscription.day)
      refute is_nil(subscription.agreement_id)

      assert {:ok, subscription} = Membership.Subscription.fetch_by_id(silver_subscription.id)
      assert subscription.status == "CANCELLED"

      assert {:ok, subscription} = Membership.Subscription.fetch_by_id(active_subscription.id)
      assert subscription.status == "ENDED"
    end

    test "success for downgrade" do
      specialist = Authentication.Factory.insert(:specialist, type: "EXTERNAL")

      active_subscription =
        Membership.Factory.insert(:accepted_subscription, %{
          specialist_id: specialist.id,
          type: "PLATINUM"
        })

      gold_subscription =
        Membership.Factory.insert(:accepted_subscription, %{
          specialist_id: specialist.id,
          type: "GOLD"
        })

      pending_subscription =
        Membership.Factory.insert(:pending_subscription, %{
          specialist_id: specialist.id,
          type: "SILVER"
        })

      mock(Telr.Gateway, :send, Telr.GatewayFixtures.check_authorised())

      assert {:ok, :PAID} = Membership.Subscription.Verify.call(pending_subscription)
      assert {:ok, subscription} = Membership.Subscription.fetch_by_id(pending_subscription.id)
      assert subscription.status == "ACCEPTED"
      refute is_nil(subscription.day)
      refute is_nil(subscription.agreement_id)

      assert {:ok, subscription} = Membership.Subscription.fetch_by_id(gold_subscription.id)
      assert subscription.status == "CANCELLED"

      assert {:ok, subscription} = Membership.Subscription.fetch_by_id(active_subscription.id)
      assert subscription.status == "CANCELLED"
    end
  end

  describe "call/2" do
    test "success for right parameters" do
      specialist = Authentication.Factory.insert(:specialist, type: "EXTERNAL")

      pending_subscription =
        Membership.Factory.insert(:pending_subscription, %{
          specialist_id: specialist.id
        })

      mock(Telr.Gateway, :send, Telr.GatewayFixtures.check_paid())

      assert {:ok, :PAID} =
               Membership.Subscription.Verify.call(specialist.id, pending_subscription.order_id)

      assert {:ok, subscription} = Membership.Subscription.fetch_by_id(pending_subscription.id)
      assert subscription.status == "ACCEPTED"
      refute is_nil(subscription.day)
      refute is_nil(subscription.agreement_id)
      assert subscription.active
      refute is_nil(subscription.accepted_at)

      # End trial
      %{trial_ends_at: trial_ends_at} = Repo.get_by(Specialist, id: specialist.id)
      assert NaiveDateTime.diff(trial_ends_at, NaiveDateTime.utc_now()) == 0
    end
  end
end
