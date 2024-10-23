defmodule TeamsWeb.PageController do
  use TeamsWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
