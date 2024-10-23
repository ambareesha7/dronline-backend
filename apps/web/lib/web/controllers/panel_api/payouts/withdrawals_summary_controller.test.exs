defmodule Web.PanelApi.Payouts.WithdrawalsSummaryControllerTest do
  use Web.ConnCase, async: true

  alias Proto.Payouts.GetWithdrawalsSummaryResponse

  describe "GET index" do
    setup [:proto_content, :authenticate_external]

    test "returns 0 values if no Pending Withdrawals exist", %{conn: conn} do
      conn = get(conn, panel_payouts_withdrawals_summary_path(conn, :show))

      assert %GetWithdrawalsSummaryResponse{
               withdrawals_summary: %Proto.Payouts.WithdrawalsSummary{
                 incoming_withdraw: 0,
                 earned_this_month: 0
               }
             } = proto_response(conn, 200, GetWithdrawalsSummaryResponse)
    end
  end
end
