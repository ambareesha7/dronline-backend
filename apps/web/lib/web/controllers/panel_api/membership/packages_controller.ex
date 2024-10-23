defmodule Web.PanelApi.Membership.PackagesController do
  use Conductor
  use Web, :controller

  action_fallback Web.FallbackController

  @authorize scopes: ["EXTERNAL", "EXTERNAL_REJECTED"]
  def index(conn, _params) do
    {:ok, packages} = Membership.fetch_packages()

    render(conn, "index.proto", %{packages: packages})
  end
end
