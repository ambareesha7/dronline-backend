defmodule Web.Api.UrgentCareController do
  use Web, :controller

  action_fallback Web.FallbackController

  def cancel_call(conn, _params) do
    current_patient_id = conn.assigns.current_patient_id

    with {:ok, _canceled_urgent_care_request} <-
           UrgentCare.PatientsQueue.Cancel.call(%{
             patient_id: current_patient_id,
             reason: :canceled_by_patient
           }) do
      send_resp(conn, 200, "")
    else
      {:error, :no_pending_urgent_care_request} ->
        send_resp(conn, 404, "no_pending_urgent_care_request")

      {:error, :refund_already_created} ->
        send_resp(conn, 406, "refund_already_created")

      {:error, :urgent_care_request_already_canceled} ->
        send_resp(conn, 406, "urgent_care_request_already_canceled")
    end
  end
end
