defmodule Payouts.WithdrawalsSummary do
  use Postgres.Service

  alias Payouts.PendingWithdrawals.PendingWithdrawal

  defstruct incoming_withdraw: 0, earned_this_month: 0

  def fetch_by_specialist_id(specialist_id) do
    incoming_withdraw =
      PendingWithdrawal
      |> where(specialist_id: ^specialist_id)
      |> Repo.aggregate(:sum, :amount)
      |> Kernel.||(0)

    earned_this_month =
      PendingWithdrawal
      |> where(specialist_id: ^specialist_id)
      |> where(
        [pw],
        fragment(
          """
              DATE_PART('year', ?) = DATE_PART('year', NOW()) AND
              DATE_PART('month', ?) = DATE_PART('month', NOW())
          """,
          pw.inserted_at,
          pw.inserted_at
        )
      )
      |> Repo.aggregate(:sum, :amount)
      |> Kernel.||(0)

    {:ok,
     %__MODULE__{
       incoming_withdraw: incoming_withdraw,
       earned_this_month: earned_this_month
     }}
  end
end
