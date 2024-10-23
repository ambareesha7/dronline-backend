defmodule Web.PanelApi.Payouts.WithdrawalsSummaryController do
  use Web, :controller
  use Conductor

  alias Payouts.WithdrawalsSummary

  action_fallback Web.FallbackController

  @authorize scopes: ["EXTERNAL"]
  def show(conn, _params) do
    specialist_id = conn.assigns.current_specialist_id

    {:ok, %WithdrawalsSummary{} = withdrawals_summary} =
      Payouts.fetch_withdrawals_summary(specialist_id)

    conn
    |> render("show.proto", %{withdrawals_summary: withdrawals_summary})
  end
end
