defmodule Payouts do
  alias Payouts.Credentials
  alias Payouts.PendingWithdrawals
  alias Payouts.WithdrawalsSummary

  defdelegate fetch_credentials(specialist_id),
    to: Credentials,
    as: :fetch_by_specialist_id

  defdelegate update_credentials(params, specialist_id),
    to: Credentials,
    as: :update

  defdelegate create_pending_withdrawal(patient_id, record_id, specialist_id),
    to: PendingWithdrawals,
    as: :create

  defdelegate fetch_pending_withdrawals(specialist_id),
    to: PendingWithdrawals,
    as: :fetch

  defdelegate fetch_withdrawals_summary(specialist_id),
    to: WithdrawalsSummary,
    as: :fetch_by_specialist_id
end
