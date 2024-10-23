defmodule TeamsWeb.TeamController do
  use TeamsWeb, :controller

  def index(conn, _params) do
    team_id = conn.assigns.team_id

    members = Teams.get_members(team_id)

    {:ok, profiles} =
      members
      |> Enum.map(& &1.specialist_id)
      |> SpecialistProfile.fetch_basic_infos()

    render(conn, "index.html", team_members: profiles)
  end

  def add_member(conn, params) do
    team_id = conn.assigns.team_id
    email = params["team_invitation"]["email"]

    with {:ok, specialist} <- Authentication.Specialist.fetch_by_email(email),
         :ok <- Teams.add_to_team(team_id: team_id, specialist_id: specialist.id) do
      conn
      |> put_flash(:info, "Specialist added to the team")
      |> redirect(to: "/teams")
    else
      {:error, :already_in_a_team} ->
        conn
        |> put_flash(:error, "The specialist is already in a different team.")
        |> redirect(to: "/teams")

      {:error, :not_found} ->
        conn
        |> put_flash(:error, "Specialist not found")
        |> redirect(to: "/teams")
    end
  end

  def remove_member(conn, %{"specialist_id" => specialist_id}) do
    team_id = conn.assigns.team_id

    :ok = Teams.remove_from_team(team_id: team_id, specialist_id: specialist_id)

    conn
    |> put_flash(:info, "Specialist removed from the team")
    |> redirect(to: "/teams")
  end
end
