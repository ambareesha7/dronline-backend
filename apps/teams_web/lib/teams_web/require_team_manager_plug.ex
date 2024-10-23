defmodule TeamsWeb.RequireTeamManagerPlug do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    case Plug.Conn.get_session(conn, :team_id) do
      id when is_integer(id) ->
        assign(conn, :team_id, id)

      nil ->
        conn
        |> Phoenix.Controller.redirect(to: "/teams/sign_in")
        |> halt()
    end
  end
end
