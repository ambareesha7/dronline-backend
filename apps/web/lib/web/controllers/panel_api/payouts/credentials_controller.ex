defmodule Web.PanelApi.Payouts.CredentialsController do
  use Web, :controller
  use Conductor

  action_fallback Web.FallbackController

  @authorize scopes: ["EXTERNAL"]
  def show(conn, _params) do
    specialist_id = conn.assigns.current_specialist_id

    {:ok, credentials} = Payouts.fetch_credentials(specialist_id)

    conn
    |> render("show.proto", %{credentials: credentials})
  end

  @decode Proto.Payouts.UpdateCredentialsRequest
  def update(conn, _params) do
    specialist_id = conn.assigns.current_specialist_id
    credentials_proto = conn.assigns.protobuf.credentials |> Map.from_struct()

    with {:ok, credentials} <- Payouts.update_credentials(credentials_proto, specialist_id) do
      conn
      |> render("show.proto", %{credentials: credentials})
    end
  end
end
