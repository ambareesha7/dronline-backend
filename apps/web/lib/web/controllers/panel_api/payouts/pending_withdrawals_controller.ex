defmodule Web.PanelApi.Payouts.PendingWithdrawalsController do
  use Web, :controller
  use Conductor

  action_fallback Web.FallbackController

  @authorize scopes: ["EXTERNAL"]
  def index(conn, _params) do
    specialist_id = conn.assigns.current_specialist_id

    {:ok, pending_withdrawals} = Payouts.fetch_pending_withdrawals(specialist_id)

    patient_ids = Enum.map(pending_withdrawals, & &1.patient_id)
    patients_generic_data = Web.PatientGenericData.get_by_ids(patient_ids)

    conn
    |> render("index.proto", %{
      pending_withdrawals: pending_withdrawals,
      patients: patients_generic_data
    })
  end
end
