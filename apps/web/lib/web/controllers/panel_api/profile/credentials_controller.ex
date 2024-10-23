defmodule Web.PanelApi.Profile.CredentialsController do
  use Web, :controller

  action_fallback Web.FallbackController

  def show(conn, _params) do
    specialist_id = conn.assigns.current_specialist_id

    {:ok, credentials} = Authentication.fetch_specialist_by_id(specialist_id)

    conn |> render("show.proto", %{credentials: credentials})
  end
end
