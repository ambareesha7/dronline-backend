defmodule Web.AdminApi.InternalSpecialistsController do
  use Web, :controller

  action_fallback Web.FallbackController

  @decode Proto.AdminPanel.CreateInternalSpecialistRequest
  def create(conn, _params) do
    params = conn.assigns.protobuf.internal_specialist_account

    with {:ok, internal_specialist} <- Admin.create_internal_specialist(params) do
      render(conn, "create.proto", %{internal_specialist: internal_specialist})
    end
  end

  def index(conn, params) do
    {:ok, internal_specialists, next_token} = Admin.fetch_internal_specialists(params)

    render(conn, "index.proto", %{
      internal_specialists: internal_specialists,
      next_token: next_token
    })
  end

  def show(conn, params) do
    specialist_id = params["id"]

    with {:ok, internal_specialist} <- Admin.fetch_internal_specialist(specialist_id) do
      render(conn, "show.proto", %{internal_specialist: internal_specialist})
    end
  end
end
