defmodule Web.PanelApi.Payouts.WithdrawalsSummaryView do
  use Web, :view

  def render("show.proto", %{
        withdrawals_summary: %{
          earned_this_month: earned_this_month,
          incoming_withdraw: incoming_withdraw
        }
      }) do
    %{
      withdrawals_summary: %Proto.Payouts.WithdrawalsSummary{
        earned_this_month: earned_this_month,
        incoming_withdraw: incoming_withdraw
      }
    }
    |> Proto.validate!(Proto.Payouts.GetWithdrawalsSummaryResponse)
    |> Proto.Payouts.GetWithdrawalsSummaryResponse.new()
  end
end
