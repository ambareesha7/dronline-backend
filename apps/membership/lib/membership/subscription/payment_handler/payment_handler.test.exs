defmodule Membership.Subscription.PaymentHandlerTest do
  use Postgres.DataCase, async: true

  import Mockery

  alias Membership.Subscription
  alias Membership.Telr

  describe "verify_payments" do
    test "success for cancelled status" do
      checked_long_time_ago = Timex.now() |> Timex.shift(months: -1)

      specialist = Authentication.Factory.insert(:specialist, type: "EXTERNAL")

      due_subscription =
        Membership.Factory.insert(:accepted_subscription, %{
          checked_at: checked_long_time_ago,
          specialist_id: specialist.id,
          next_payment_date: Timex.today() |> Timex.shift(months: -1)
        })

      mock(Telr.Tools, :get_agreement, Telr.ToolsFixtures.get_agreement_cancelled())

      assert :ok = Subscription.PaymentHandler.verify_payments()

      {:ok, subscription} = Subscription.fetch_by_id(due_subscription.id)

      assert subscription.status == "ENDED"
      refute subscription.active
    end

    test "success for active status and found payment for next month" do
      checked_long_time_ago = Timex.now() |> Timex.shift(months: -1)

      specialist = Authentication.Factory.insert(:specialist, type: "EXTERNAL")

      due_subscription =
        Membership.Factory.insert(:accepted_subscription, %{
          checked_at: checked_long_time_ago,
          specialist_id: specialist.id,
          next_payment_date: Timex.today() |> Timex.shift(months: -1),
          day: Timex.today() |> Timex.shift(months: -1) |> Timex.day()
        })

      mock(Telr.Tools, :get_agreement, Telr.ToolsFixtures.get_agreement_active())
      mock(Telr.Tools, :get_agreement_history, Telr.ToolsFixtures.get_agreement_history_paid())

      assert :ok = Subscription.PaymentHandler.verify_payments()

      {:ok, subscription} = Subscription.fetch_by_id(due_subscription.id)

      assert subscription.status == "ACCEPTED"

      assert subscription.next_payment_date ==
               due_subscription.next_payment_date
               |> Timex.shift(months: 1)
               |> Timex.set(day: due_subscription.day)

      assert subscription.next_payment_count == due_subscription.next_payment_count + 1
      assert subscription.active
    end

    test "success for active status and not found payment for next month" do
      checked_long_time_ago = Timex.now() |> Timex.shift(months: -1)

      specialist = Authentication.Factory.insert(:specialist, type: "EXTERNAL")

      due_subscription =
        Membership.Factory.insert(:accepted_subscription, %{
          checked_at: checked_long_time_ago,
          specialist_id: specialist.id,
          next_payment_date: Timex.today() |> Timex.shift(months: -1)
        })

      mock(Telr.Tools, :get_agreement, Telr.ToolsFixtures.get_agreement_active())

      mock(
        Telr.Tools,
        :get_agreement_history,
        Telr.ToolsFixtures.get_agreement_history_not_paid()
      )

      assert :ok = Subscription.PaymentHandler.verify_payments()

      {:ok, subscription} = Subscription.fetch_by_id(due_subscription.id)

      assert subscription.status == "ACCEPTED"
      assert subscription.next_payment_date == due_subscription.next_payment_date
      assert subscription.next_payment_count == due_subscription.next_payment_count
      assert subscription.active
    end

    test "success for failed status" do
      checked_long_time_ago = Timex.now() |> Timex.shift(months: -1)

      specialist = Authentication.Factory.insert(:specialist, type: "EXTERNAL")

      due_subscription =
        Membership.Factory.insert(:accepted_subscription, %{
          checked_at: checked_long_time_ago,
          specialist_id: specialist.id,
          next_payment_date: Timex.today() |> Timex.shift(months: -1)
        })

      mock(Telr.Tools, :get_agreement, Telr.ToolsFixtures.get_agreement_failed())

      assert :ok = Subscription.PaymentHandler.verify_payments()

      {:ok, subscription} = Subscription.fetch_by_id(due_subscription.id)

      assert subscription.status == "ENDED"
      refute subscription.active
    end
  end
end
