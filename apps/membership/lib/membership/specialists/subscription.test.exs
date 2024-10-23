defmodule Membership.Specialists.SubscriptionTest do
  use Postgres.DataCase, async: true

  alias Membership.Specialists.Specialist
  alias Membership.Specialists.Subscription

  describe "fetch/1" do
    test "returns PLATINUM if trial is active" do
      specialist = Authentication.Factory.insert(:specialist, type: "EXTERNAL")

      _not_active_subscription =
        Membership.Factory.insert(:pending_subscription, specialist_id: specialist.id)

      assert {:ok, subscription, _, _} = Subscription.fetch(specialist.id)
      assert subscription.type == "PLATINUM"
    end

    test "returns BASIC if trial is not active" do
      specialist = Authentication.Factory.insert(:specialist, type: "EXTERNAL")

      Specialist
      |> where(id: ^specialist.id)
      |> Repo.update_all(set: [trial_ends_at: NaiveDateTime.utc_now()])

      _not_active_subscription =
        Membership.Factory.insert(:pending_subscription, specialist_id: specialist.id)

      assert {:ok, subscription, _, _} = Subscription.fetch(specialist.id)
      assert subscription.type == "BASIC"
    end

    test "returns active (in this case GOLD) if trial is not active" do
      specialist = Authentication.Factory.insert(:specialist, type: "EXTERNAL")

      Specialist
      |> where(id: ^specialist.id)
      |> Repo.update_all(set: [trial_ends_at: NaiveDateTime.utc_now()])

      _active_subscription =
        Membership.Factory.insert(:accepted_subscription,
          specialist_id: specialist.id,
          type: "GOLD"
        )

      assert {:ok, subscription, _, _} = Subscription.fetch(specialist.id)
      assert subscription.type == "GOLD"
    end
  end

  describe "fetch_by_order_id/2" do
    test "returns {:ok, subscription} when params are valid" do
      specialist = Authentication.Factory.insert(:specialist, type: "EXTERNAL")
      subscription = Membership.Factory.insert(:subscription, specialist_id: specialist.id)

      assert {:ok, fetched_subscription} =
               Subscription.fetch_by_order_id(specialist.id, subscription.order_id)

      assert subscription.order_id == fetched_subscription.order_id
    end

    test "returns {:error, :not_found} when subscription with given order_id doesn't belong to the specialist" do
      specialist = Authentication.Factory.insert(:specialist, type: "EXTERNAL")
      subscription = Membership.Factory.insert(:subscription, specialist_id: specialist.id)

      assert {:error, :not_found} = Subscription.fetch_by_order_id(0, subscription.order_id)
    end

    test "returns {:error, :not_found} when subscription doesn't exist" do
      specialist = Authentication.Factory.insert(:specialist, type: "EXTERNAL")

      assert {:error, :not_found} = Subscription.fetch_by_order_id(specialist.id, "0")
    end
  end

  describe "fetch_accepted/2" do
    test "returns only not active and accepted subscription" do
      specialist = Authentication.Factory.insert(:specialist, type: "EXTERNAL")

      _active_subscription =
        Membership.Factory.insert(:accepted_subscription, specialist_id: specialist.id)

      not_active_subscription =
        Membership.Factory.insert(:accepted_subscription, specialist_id: specialist.id)

      assert {:ok, fetched_subscription} = Subscription.fetch_accepted(specialist.id)
      assert fetched_subscription.id == not_active_subscription.id
    end
  end

  describe "fetch_pending/1" do
    test "returns only pending subscription" do
      specialist = Authentication.Factory.insert(:specialist, type: "EXTERNAL")

      _active_subscription =
        Membership.Factory.insert(:accepted_subscription, specialist_id: specialist.id)

      pending_subscription =
        Membership.Factory.insert(:pending_subscription, specialist_id: specialist.id)

      assert {:ok, fetched_subscription} = Subscription.fetch_pending(specialist.id)
      assert fetched_subscription.id == pending_subscription.id
    end
  end
end
