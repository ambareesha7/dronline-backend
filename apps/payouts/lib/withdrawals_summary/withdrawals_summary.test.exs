defmodule Payouts.WithdrawalsSummaryTest do
  use Postgres.DataCase, async: true

  alias Payouts.WithdrawalsSummary

  describe "fetch_by_specialist_id/1" do
    test "fetches withdrawals summary if they exist" do
      specialist_id = 1
      patient_id = 2
      medical_category_id = 3

      _pending_withdrawal_1 =
        Payouts.Factory.insert(:pending_withdrawal,
          patient_id: patient_id,
          record_id: 1,
          specialist_id: specialist_id,
          amount: 10,
          medical_category_id: medical_category_id
        )

      _pending_withdrawal_2 =
        Payouts.Factory.insert(:pending_withdrawal,
          patient_id: patient_id,
          record_id: 2,
          specialist_id: specialist_id,
          amount: 20,
          medical_category_id: medical_category_id,
          inserted_at: ~N[2010-01-01 01:00:00.000000]
        )

      assert {:ok,
              %WithdrawalsSummary{
                incoming_withdraw: 30,
                earned_this_month: 10
              }} = WithdrawalsSummary.fetch_by_specialist_id(specialist_id)
    end
  end
end
