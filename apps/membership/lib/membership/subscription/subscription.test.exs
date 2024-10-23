defmodule Membership.SubscriptionTest do
  use Postgres.DataCase, async: true

  alias Membership.Subscription

  describe "create/1" do
    test "creates subscription when params are valid" do
      specialist = Authentication.Factory.insert(:specialist, type: "EXTERNAL")

      params = %{
        specialist_id: specialist.id,
        order_id: UUID.uuid4(:hex),
        next_payment_date: DateTime.utc_now(),
        ref: "RANDOMSTRING",
        type: "PLATINUM",
        webview_url: "php://terl.co"
      }

      assert {:ok, %Subscription{}} = Subscription.create(params)
    end

    test "fails when params are invalid" do
      assert {:error, %Ecto.Changeset{}} = Subscription.create(%{})
    end
  end

  describe "update/2" do
    test "updates subscription when params are valid" do
      specialist = Authentication.Factory.insert(:specialist, type: "EXTERNAL")
      subscription = Membership.Factory.insert(:subscription, specialist_id: specialist.id)

      params = %{
        ref: "ref"
      }

      assert {:ok, %Subscription{ref: "ref"}} = Subscription.update(subscription.id, params)
    end

    test "fails when params are invalid" do
      specialist = Authentication.Factory.insert(:specialist, type: "EXTERNAL")
      subscription = Membership.Factory.insert(:subscription, specialist_id: specialist.id)

      params = %{next_payment_date: "wrong_type"}

      assert {:error, %Ecto.Changeset{}} = Subscription.update(subscription.id, params)
    end
  end

  describe "get_pending_to_verify/0" do
    test "returns {:ok, []} when there are no subscriptions which meet conditions" do
      assert {:ok, []} = Subscription.get_pending_to_verify()
    end

    test "returns list of PENDING subscriptions which weren't checked for defined interval" do
      specialist = Authentication.Factory.insert(:specialist, type: "EXTERNAL")

      checked_long_time_ago = Timex.now() |> Timex.shift(months: -1)

      _accepted_subscription =
        Membership.Factory.insert(:accepted_subscription, %{
          checked_at: checked_long_time_ago,
          specialist_id: specialist.id
        })

      _pending_subscription =
        Membership.Factory.insert(:pending_subscription, %{
          checked_at: checked_long_time_ago,
          specialist_id: specialist.id
        })

      assert {:ok, subscriptions} = Subscription.get_pending_to_verify()
      assert length(subscriptions) == 1
    end
  end

  describe "fetch_due_subscriptions/0" do
    test "returns {:ok, []} when there are no subscriptions which meet conditions" do
      assert {:ok, []} = Subscription.fetch_due_subscriptions()
    end

    test "returns list of active subscriptions which are due and weren't checked for defined interval" do
      specialist = Authentication.Factory.insert(:specialist, type: "EXTERNAL")
      specialist2 = Authentication.Factory.insert(:specialist, type: "EXTERNAL")

      checked_long_time_ago = Timex.now() |> Timex.shift(months: -1)

      due_subscription =
        Membership.Factory.insert(:accepted_subscription, %{
          checked_at: checked_long_time_ago,
          specialist_id: specialist.id,
          next_payment_date: Timex.today() |> Timex.shift(months: -1)
        })

      _not_due_subscription =
        Membership.Factory.insert(:accepted_subscription, %{
          checked_at: checked_long_time_ago,
          specialist_id: specialist2.id
        })

      assert {:ok, [subscription]} = Subscription.fetch_due_subscriptions()
      assert subscription.id == due_subscription.id
    end
  end

  describe "activation trigger" do
    test "on subscription activation should set subscription type as specialist's pacakge type" do
      specialist = Authentication.Factory.insert(:specialist, type: "EXTERNAL")

      subscription =
        Membership.Factory.insert(:accepted_subscription, specialist_id: specialist.id)

      {:ok, updated_specialist} = Repo.fetch(Authentication.Specialist, specialist.id)

      assert subscription.active
      assert subscription.type == updated_specialist.package_type
    end

    test "on subscription deactivation should set subscription type to BASIC" do
      specialist = Authentication.Factory.insert(:specialist, type: "EXTERNAL")

      subscription =
        Membership.Factory.insert(:accepted_subscription, specialist_id: specialist.id)

      {:ok, updated_specialist} = Repo.fetch(Authentication.Specialist, specialist.id)

      assert subscription.active
      assert subscription.type == updated_specialist.package_type

      assert {:ok, subscription} =
               Membership.Subscription.update(subscription.id, %{
                 status: "ENDED",
                 ended_at: Timex.now()
               })

      {:ok, updated_specialist} = Repo.fetch(Authentication.Specialist, specialist.id)

      refute subscription.active
      assert updated_specialist.package_type == "BASIC"
    end

    test "on subscription activation should leave active old one" do
      specialist = Authentication.Factory.insert(:specialist, type: "EXTERNAL")

      active_subscription =
        Membership.Factory.insert(:accepted_subscription, specialist_id: specialist.id)

      not_active_subscription =
        Membership.Factory.insert(:accepted_subscription, specialist_id: specialist.id)

      assert active_subscription.active
      refute not_active_subscription.active
    end

    test "on subscription activation should set it to active when there is no other active" do
      specialist = Authentication.Factory.insert(:specialist, type: "EXTERNAL")

      subscription =
        Membership.Factory.insert(:accepted_subscription, specialist_id: specialist.id)

      assert {:ok, ended_subscription} =
               Membership.Subscription.update(subscription.id, %{
                 status: "ENDED",
                 ended_at: Timex.now()
               })

      new_subscription =
        Membership.Factory.insert(:accepted_subscription, specialist_id: specialist.id)

      refute ended_subscription.active
      assert new_subscription.active
    end
  end
end
