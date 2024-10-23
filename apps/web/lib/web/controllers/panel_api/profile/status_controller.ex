defmodule Web.PanelApi.Profile.StatusController do
  use Web, :controller

  action_fallback Web.FallbackController

  def show(conn, _params) do
    specialist_id = conn.assigns.current_specialist_id

    {:ok, status} = SpecialistProfile.fetch_status(specialist_id)

    conn |> render("show.proto", %{status: status})
  end
end
