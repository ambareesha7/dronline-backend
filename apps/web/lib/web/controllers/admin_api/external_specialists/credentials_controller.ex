defmodule Web.AdminApi.ExternalSpecialists.CredentialsController do
  use Web, :controller

  action_fallback Web.FallbackController

  def show(conn, params) do
    specialist_id = params["specialist_id"]

    {:ok, credentials} = Authentication.fetch_specialist_by_id(specialist_id)

    conn
    |> put_view(Web.AdminApi.Specialists.CredentialsView)
    |> render("show.proto", %{credentials: credentials})
  end
end
