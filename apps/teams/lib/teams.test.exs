defmodule TeamsTest do
  use Postgres.DataCase, async: true

  test "doctors can be added to a team" do
    {:ok, %{id: team_id}} = Teams.create_team(random_id(), %{})
    specialist_id = random_id()

    :ok = add_to_team(team_id: team_id, specialist_id: specialist_id)

    assert Teams.specialist_team_id(specialist_id) == team_id
  end

  test "doctor can see the team invitations" do
    {:ok, %{id: team_id}} = Teams.create_team(random_id(), %{})
    specialist_id = random_id()

    :ok = Teams.add_to_team(team_id: team_id, specialist_id: specialist_id)

    assert [%Teams.Invitation{team_id: ^team_id}] = Teams.get_invitations(specialist_id)
  end

  test "members can be upgraded to admin" do
    owner_id = random_id()
    {:ok, %{id: team_id}} = Teams.create_team(owner_id, %{})
    specialist_id = random_id()

    :ok = add_to_team(team_id: team_id, specialist_id: specialist_id)
    :ok = Teams.set_admin_role(owner_id, specialist_id)

    role =
      team_id
      |> Teams.get_members()
      |> Enum.find(&(&1.specialist_id == specialist_id))
      |> Map.get(:role)

    assert role == "admin"
  end

  test "only the owner can grant/revoke admin role" do
    owner_id = random_id()
    {:ok, %{id: team_id}} = Teams.create_team(owner_id, %{})
    admin_id = random_id()
    specialist_id = random_id()

    :ok = add_to_team(team_id: team_id, specialist_id: admin_id)
    :ok = add_to_team(team_id: team_id, specialist_id: specialist_id)

    :ok = Teams.set_admin_role(owner_id, admin_id)

    assert {:error, :unauthorized} = Teams.set_admin_role(admin_id, specialist_id)
    assert {:error, :unauthorized} = Teams.revoke_admin_role(admin_id, specialist_id)
  end

  test "members can be downgraded from admin" do
    owner_id = random_id()
    {:ok, %{id: team_id}} = Teams.create_team(owner_id, %{})
    specialist_id = random_id()

    :ok = add_to_team(team_id: team_id, specialist_id: specialist_id)
    :ok = Teams.set_admin_role(owner_id, specialist_id)
    :ok = Teams.revoke_admin_role(owner_id, specialist_id)

    role =
      team_id
      |> Teams.get_members()
      |> Enum.find(&(&1.specialist_id == specialist_id))
      |> Map.get(:role)

    assert role == "member"
  end

  test "doctors can be removed from a team" do
    owner_id = random_id()
    {:ok, %{id: team_id}} = Teams.create_team(owner_id, %{})
    specialist_id = random_id()

    :ok = add_to_team(team_id: team_id, specialist_id: specialist_id)
    :ok = Teams.remove_from_team(team_id: team_id, specialist_id: specialist_id)

    assert get_member_ids(team_id) == [owner_id]
  end

  test "adding specialist to the same team is idempotent" do
    {:ok, %{id: team_id}} = Teams.create_team(random_id(), %{})
    specialist_id = random_id()

    :ok = add_to_team(team_id: team_id, specialist_id: specialist_id)
    :ok = add_to_team(team_id: team_id, specialist_id: specialist_id)
  end

  test "a specialist can be only in a single team" do
    {:ok, %{id: team_a_id}} = Teams.create_team(random_id(), %{})
    {:ok, %{id: team_b_id}} = Teams.create_team(random_id(), %{})
    specialist_id = random_id()

    :ok = add_to_team(team_id: team_a_id, specialist_id: specialist_id)

    assert {:error, _} = add_to_team(team_id: team_b_id, specialist_id: specialist_id)
  end

  test "teams can be searched by location" do
    {:ok, %{id: team_a_id}} =
      Teams.create_team(random_id(), %{
        location: %Geo.Point{coordinates: {10.0, 10.0}, srid: 4326}
      })

    {:ok, _} =
      Teams.create_team(random_id(), %{location: %Geo.Point{coordinates: {5.0, 5.0}, srid: 4326}})

    assert [%{id: ^team_a_id}] =
             Teams.teams_in_area(%{latitude: 10.0, longitude: 10.0}, distance_in_meters: 1000)
  end

  test "team location can be changed" do
    {:ok, team} = Teams.create_team(random_id(), %{})

    lat = 5.0
    lon = 0.0

    :ok = Teams.set_location(team.id, %{latitude: lat, longitude: lon, formatted_address: "Test"})

    assert %{location: %{latitude: ^lat, longitude: ^lon}, formatted_address: "Test"} =
             Teams.team_details(team.id)
  end

  test "a person managing a team can log in" do
    identifier = "test_team"
    password = UUID.uuid4()

    {:ok, %{id: team_id}} = Teams.create_team(random_id(), %{})

    :ok = Teams.Authentication.register_team_manager(team_id, identifier, password)

    assert {:error, :incorrect_credentials} =
             Teams.Authentication.team_id(identifier, "incorrect")

    assert {:ok, ^team_id} = Teams.Authentication.team_id(identifier, password)
  end

  test "admin can set name and logo_url" do
    owner_id = random_id()
    {:ok, %{id: team_id}} = Teams.create_team(owner_id, %{})

    :ok = Teams.set_branding(team_id, %{name: "Test clinic", logo_url: "logo_url"})

    assert %{name: "Test clinic", logo_url: "logo_url"} = Teams.team_details(team_id)
  end

  defp random_id, do: :rand.uniform(1000)

  defp get_member_ids(team_id) do
    team_id
    |> Teams.get_members()
    |> Enum.map(& &1.specialist_id)
  end

  defp add_to_team(opts) do
    :ok = Teams.add_to_team(opts)
    Teams.accept_invitation(opts)
  end
end
