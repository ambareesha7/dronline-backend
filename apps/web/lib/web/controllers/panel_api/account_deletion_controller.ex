defmodule Web.PanelApi.AccountDeletionController do
  use Web, :controller

  action_fallback Web.FallbackController

  @decode Proto.PanelAuthentication.SendSpecialistAccountDeletionRequest
  def delete_account(conn, _params) do
    specialist_id = conn.assigns.current_specialist_id

    with {:ok, _account_deletion} <-
           Authentication.Specialist.AccountDeletion.create(%{specialist_id: specialist_id}) do
      conn |> send_resp(200, "")
    else
      {:error, %Ecto.Changeset{errors: [specialist_id: {"has already been taken", _}]}} ->
        {:error, "Your request is already being processed by the DrOnline Team."}
    end
  end
end
