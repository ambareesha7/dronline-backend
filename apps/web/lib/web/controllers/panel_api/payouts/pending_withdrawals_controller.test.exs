defmodule Web.PanelApi.Payouts.PendingWithdrawalsControllerTest do
  use Web.ConnCase, async: true

  alias Proto.Payouts.GetPendingWithdrawalsResponse
  alias Proto.Payouts.PendingWithdrawal

  describe "GET index" do
    setup [:proto_content, :authenticate_external]

    test "returns pending withdrawals", %{conn: conn, current_external: current_external} do
      patient_id = 1
      specialist_id = current_external.id
      medical_category_id = 3
      record_id = 4

      _prices =
        SpecialistProfile.Factory.insert(:prices, %{
          specialist_id: specialist_id,
          medical_category_id: medical_category_id,
          price_minutes_15: 99
        })

      visit =
        Visits.Factory.insert(:ended_visit,
          specialist_id: specialist_id,
          patient_id: patient_id,
          chosen_medical_category_id: medical_category_id,
          record_id: record_id
        )

      _pending_withdrawal =
        Payouts.Factory.insert(:pending_withdrawal,
          patient_id: patient_id,
          record_id: record_id,
          visit_id: visit.id,
          specialist_id: specialist_id,
          medical_category_id: medical_category_id,
          amount: 99
        )

      conn = get(conn, panel_payouts_pending_withdrawals_path(conn, :index))

      assert %GetPendingWithdrawalsResponse{
               pending_withdrawals: [
                 %PendingWithdrawal{
                   record_id: 4
                 }
               ]
             } = proto_response(conn, 200, GetPendingWithdrawalsResponse)
    end
  end
end
