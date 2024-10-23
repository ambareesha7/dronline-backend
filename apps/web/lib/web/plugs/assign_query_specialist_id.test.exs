defmodule Web.Plugs.AssignQuerySpecialistIdTest do
  use Web.ConnCase, async: true

  alias Web.Plugs.AssignQuerySpecialistId

  test "assigns data if token is valid", %{
    conn: conn
  } do
    owner_id = random_id()
    {:ok, %{id: team_id}} = Teams.create_team(owner_id, %{})

    team_admin = Authentication.Factory.insert(:specialist)

    :ok = add_to_team(team_id: team_id, specialist_id: team_admin.id)
    :ok = Teams.set_admin_role(owner_id, team_admin.id)

    team_member = Authentication.Factory.insert(:specialist)
    :ok = add_to_team(team_id: team_id, specialist_id: team_member.id)

    conn =
      %{conn | params: %{"specialist_id" => team_member.id}}
      |> merge_assigns(current_specialist_id: team_admin.id)
      |> AssignQuerySpecialistId.call(%{})

    assert conn.assigns.query_specialist_id == team_member.id
    refute conn.halted
  end

  test "returns 401 if specialist_id doesn't belong to team", %{conn: conn} do
    owner_id = random_id()
    {:ok, %{id: team_id}} = Teams.create_team(owner_id, %{})

    team_admin = Authentication.Factory.insert(:specialist)

    :ok = add_to_team(team_id: team_id, specialist_id: team_admin.id)
    :ok = Teams.set_admin_role(owner_id, team_admin.id)

    not_a_team_member = Authentication.Factory.insert(:specialist)

    conn =
      %{conn | params: %{"specialist_id" => not_a_team_member.id}}
      |> merge_assigns(current_specialist_id: team_admin.id)
      |> AssignQuerySpecialistId.call(%{})

    assert response(conn, 401)
  end

  defp random_id, do: :rand.uniform(1000)

  defp add_to_team(opts) do
    :ok = Teams.add_to_team(opts)
    Teams.accept_invitation(opts)
  end
end
