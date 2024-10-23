defmodule Web.PanelApi.Payouts.PendingWithdrawalsView do
  use Web, :view

  def render("index.proto", %{
        pending_withdrawals: pending_withdrawals,
        patients: patients_generic_data
      }) do
    %{
      pending_withdrawals:
        Enum.map(pending_withdrawals, fn pending_withdrawal ->
          %Proto.Payouts.PendingWithdrawal{
            patient_id: pending_withdrawal.patient_id,
            medical_category_id: pending_withdrawal.medical_category_id,
            record_id: pending_withdrawal.record_id,
            amount: pending_withdrawal.amount,
            inserted_at: pending_withdrawal.inserted_at |> Timex.to_unix()
          }
        end),
      patients:
        Enum.map(
          patients_generic_data,
          &Web.View.Generics.render_patient/1
        )
    }
    |> Proto.validate!(Proto.Payouts.GetPendingWithdrawalsResponse)
    |> Proto.Payouts.GetPendingWithdrawalsResponse.new()
  end
end
