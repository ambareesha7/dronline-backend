defmodule Membership.Subscription.CreateTest do
  use Postgres.DataCase, async: true

  alias Membership.Subscription

  describe "call/2" do
    test "returns {:ok, nil} when basic profile is selected" do
      specialist = Authentication.Factory.insert(:verified_specialist)

      assert {:ok, nil} = Membership.Subscription.Create.call(specialist.id, "BASIC")
    end

    test "success when there is no active subscription" do
      specialist = Authentication.Factory.insert(:verified_specialist)
      SpecialistProfile.Factory.insert(:location, specialist_id: specialist.id)
      SpecialistProfile.Factory.insert(:basic_info, specialist_id: specialist.id)

      assert {:ok, _url} = Membership.Subscription.Create.call(specialist.id, "GOLD")
    end

    test "success when upgrading" do
      specialist = Authentication.Factory.insert(:verified_specialist)
      SpecialistProfile.Factory.insert(:location, specialist_id: specialist.id)
      SpecialistProfile.Factory.insert(:basic_info, specialist_id: specialist.id)

      old_subscription =
        Membership.Factory.insert(:accepted_subscription,
          specialist_id: specialist.id,
          type: "SILVER"
        )

      assert {:ok, _url} = Membership.Subscription.Create.call(specialist.id, "GOLD")

      {:ok, old_subscription} = Subscription.fetch_by_id(old_subscription.id)
      assert %Subscription{status: "ACCEPTED"} = old_subscription
    end

    test "success when downgrading" do
      specialist = Authentication.Factory.insert(:verified_specialist)
      SpecialistProfile.Factory.insert(:location, specialist_id: specialist.id)
      SpecialistProfile.Factory.insert(:basic_info, specialist_id: specialist.id)

      old_subscription =
        Membership.Factory.insert(:accepted_subscription,
          specialist_id: specialist.id,
          type: "PLATINUM"
        )

      assert {:ok, _url} = Membership.Subscription.Create.call(specialist.id, "GOLD")

      {:ok, old_subscription} = Subscription.fetch_by_id(old_subscription.id)
      assert %Subscription{status: "ACCEPTED"} = old_subscription
    end

    test "success when downgrading to basic" do
      specialist = Authentication.Factory.insert(:verified_specialist)
      SpecialistProfile.Factory.insert(:location, specialist_id: specialist.id)
      SpecialistProfile.Factory.insert(:basic_info, specialist_id: specialist.id)

      old_subscription =
        Membership.Factory.insert(:accepted_subscription,
          specialist_id: specialist.id,
          type: "PLATINUM"
        )

      assert {:ok, _url} = Membership.Subscription.Create.call(specialist.id, "BASIC")

      {:ok, old_subscription} = Subscription.fetch_by_id(old_subscription.id)
      assert %Subscription{status: "CANCELLED"} = old_subscription
    end

    test "success when there are 2 accepted subscriptions" do
      specialist = Authentication.Factory.insert(:verified_specialist)
      SpecialistProfile.Factory.insert(:location, specialist_id: specialist.id)
      SpecialistProfile.Factory.insert(:basic_info, specialist_id: specialist.id)

      active_subscription =
        Membership.Factory.insert(:accepted_subscription,
          specialist_id: specialist.id,
          type: "PLATINUM"
        )

      accepted_subscription =
        Membership.Factory.insert(:accepted_subscription,
          specialist_id: specialist.id,
          type: "GOLD"
        )

      assert {:ok, _url} = Membership.Subscription.Create.call(specialist.id, "SILVER")

      {:ok, active_subscription} = Subscription.fetch_by_id(active_subscription.id)
      assert %Subscription{status: "ACCEPTED"} = active_subscription

      {:ok, accepted_subscription} = Subscription.fetch_by_id(accepted_subscription.id)
      assert %Subscription{status: "ACCEPTED"} = accepted_subscription
    end

    test "If second pending subscription is created - mark previous with status:ABANDONED" do
      specialist = Authentication.Factory.insert(:verified_specialist)
      SpecialistProfile.Factory.insert(:location, specialist_id: specialist.id)
      SpecialistProfile.Factory.insert(:basic_info, specialist_id: specialist.id)

      Membership.Factory.insert(:pending_subscription,
        specialist_id: specialist.id,
        type: "PLATINUM"
      )

      assert {:ok, url} = Membership.Subscription.Create.call(specialist.id, "GOLD")

      assert [abandoned_subscription] =
               Membership.Subscription
               |> where([s], s.status == "ABANDONED" and s.type == "PLATINUM")
               |> Postgres.Repo.all()

      assert url != abandoned_subscription.webview_url
    end

    test "returns {:error, :invalid_action} when trying subscribe the same package as active" do
      specialist = Authentication.Factory.insert(:verified_specialist)
      SpecialistProfile.Factory.insert(:location, specialist_id: specialist.id)
      SpecialistProfile.Factory.insert(:basic_info, specialist_id: specialist.id)

      Membership.Factory.insert(:accepted_subscription,
        specialist_id: specialist.id,
        type: "PLATINUM"
      )

      assert {:error, :invalid_action} =
               Membership.Subscription.Create.call(specialist.id, "PLATINUM")
    end
  end
end
