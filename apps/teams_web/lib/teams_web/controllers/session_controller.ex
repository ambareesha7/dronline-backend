defmodule TeamsWeb.SessionController do
  use TeamsWeb, :controller

  def new(conn, _) do
    render(conn, "new.html")
  end

  def create(conn, %{"identifier" => identifier, "password" => password}) do
    case Teams.Authentication.team_id(identifier, password) do
      {:ok, team_id} ->
        conn
        |> put_flash(:info, "Signed in")
        |> put_session(:team_id, team_id)
        |> redirect(to: "/teams")

      {:error, _} ->
        conn
        |> put_flash(:error, "Invalid credentials")
        |> render("new.html")
    end
  end

  def delete(conn, _) do
    conn
    |> put_flash(:info, "Signed out")
    |> delete_session(:team_id)
    |> redirect(to: "/teams/sign_in")
  end
end
