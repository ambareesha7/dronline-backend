defmodule Web.Api.AccountDeletionController do
  use Web, :controller

  action_fallback Web.FallbackController

  @decode Proto.Authentication.SendPatientAccountDeletionRequest
  def delete_account(conn, _params) do
    patient_id = conn.assigns.current_patient_id

    case Authentication.Patient.AccountDeletion.create(%{patient_id: patient_id}) do
      {:ok, _account_deletion} ->
        conn |> send_resp(200, "")

      {:error, %Ecto.Changeset{errors: [patient_id: {"has already been taken", _}]}} ->
        {:error, "Your request is already being processed by the DrOnline Team."}
    end
  end
end
