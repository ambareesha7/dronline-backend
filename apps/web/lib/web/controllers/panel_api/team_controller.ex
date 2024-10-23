defmodule Web.PanelApi.TeamController do
  use Conductor
  use Web, :controller

  alias EMR.Encounters.EncountersStats

  action_fallback(Web.FallbackController)

  @authorize scopes: [
               "GP",
               "NURSE",
               "EXTERNAL",
               {"EXTERNAL", "GOLD"},
               {"EXTERNAL", "PLATINUM"}
             ]
  def show(conn, _) do
    specialist_id = conn.assigns.current_specialist_id

    team_id = Teams.specialist_team_id(specialist_id)

    if team_id do
      is_admin = Teams.is_admin?(specialist_id)
      details = Teams.team_details(team_id)
      is_owner = details.owner_id == specialist_id

      conn
      |> render("show.proto", %{
        team_id: team_id,
        location: details[:location],
        formatted_address: details[:formatted_address],
        is_admin: is_admin,
        is_owner: is_owner,
        name: details.name,
        logo_url: details.logo_url
      })
    else
      send_resp(conn, 200, "")
    end
  end

  @authorize scopes: [
               "GP",
               "NURSE",
               "EXTERNAL",
               {"EXTERNAL", "GOLD"},
               {"EXTERNAL", "PLATINUM"}
             ]
  def create_team(conn, _) do
    specialist_id = conn.assigns.current_specialist_id

    if Teams.specialist_team_id(specialist_id) == nil do
      {:ok, team} = Teams.create_team(specialist_id, %{})
      :ok = Teams.add_to_team(team_id: team.id, specialist_id: specialist_id)
    end

    show(conn, %{})
  end

  @authorize scopes: [
               "GP",
               "NURSE",
               "EXTERNAL",
               {"EXTERNAL", "GOLD"},
               {"EXTERNAL", "PLATINUM"}
             ]
  @decode Proto.Teams.SetTeamLocation
  def set_location(conn, _) do
    specialist_id = conn.assigns.current_specialist_id
    team_id = Teams.specialist_team_id(specialist_id)
    location = conn.assigns.protobuf.location
    formatted_address = conn.assigns.protobuf.formatted_address

    :ok =
      Teams.set_location(team_id, %{
        latitude: location.lat,
        longitude: location.lon,
        formatted_address: formatted_address
      })

    send_resp(conn, 200, "")
  end

  @authorize scopes: [
               "GP",
               "NURSE",
               "EXTERNAL",
               {"EXTERNAL", "GOLD"},
               {"EXTERNAL", "PLATINUM"}
             ]
  @decode Proto.Teams.SetBranding
  def set_branding(conn, _) do
    specialist_id = conn.assigns.current_specialist_id
    team_id = Teams.specialist_team_id(specialist_id)

    branding = conn.assigns.protobuf

    :ok = Teams.set_branding(team_id, branding)

    send_resp(conn, 200, "")
  end

  @authorize scopes: [
               "GP",
               "NURSE",
               "EXTERNAL",
               {"EXTERNAL", "GOLD"},
               {"EXTERNAL", "PLATINUM"}
             ]
  def members(conn, _) do
    specialist_id = conn.assigns.current_specialist_id
    team_id = Teams.specialist_team_id(specialist_id)

    members = Teams.get_members(team_id)

    profiles =
      members
      |> Enum.map(& &1.specialist_id)
      |> Web.SpecialistGenericData.get_by_ids()
      |> Enum.reject(fn profile -> is_nil(profile.basic_info) end)
      |> Enum.map(fn profile ->
        encounters_stats = EncountersStats.get_for_specialist(profile.specialist.id)

        member = Enum.find(members, &(&1.specialist_id == profile.specialist.id))
        {member, profile, encounters_stats}
      end)

    conn
    |> render("members.proto", %{
      member_profiles: profiles
    })
  end

  @authorize scopes: [
               "GP",
               "NURSE",
               "EXTERNAL",
               {"EXTERNAL", "GOLD"},
               {"EXTERNAL", "PLATINUM"}
             ]
  @decode Proto.Teams.AddMember
  def add_member(conn, _) do
    current_specialist_id = conn.assigns.current_specialist_id
    team_id = Teams.specialist_team_id(current_specialist_id)

    specialist = get_specialist(conn.assigns.protobuf)
    :ok = Teams.add_to_team(team_id: team_id, specialist_id: specialist.id)

    send_resp(conn, 200, "")
  end

  @authorize scopes: [
               "GP",
               "NURSE",
               "EXTERNAL",
               {"EXTERNAL", "GOLD"},
               {"EXTERNAL", "PLATINUM"}
             ]
  @decode Proto.Teams.SetRole
  def set_role(conn, %{"specialist_id" => specialist_id}) do
    current_specialist_id = conn.assigns.current_specialist_id

    new_role = conn.assigns.protobuf.new_role |> Proto.Teams.Role.value()

    if new_role == 2 do
      :ok = Teams.set_admin_role(current_specialist_id, specialist_id)
    else
      :ok = Teams.revoke_admin_role(current_specialist_id, specialist_id)
    end

    send_resp(conn, 200, "")
  end

  @authorize scopes: [
               "GP",
               "NURSE",
               "EXTERNAL",
               {"EXTERNAL", "GOLD"},
               {"EXTERNAL", "PLATINUM"}
             ]
  def delete_member(conn, %{"specialist_id" => specialist_id}) do
    current_specialist_id = conn.assigns.current_specialist_id
    team_id = Teams.specialist_team_id(current_specialist_id)

    :ok = Teams.remove_from_team(team_id: team_id, specialist_id: specialist_id)

    send_resp(conn, 200, "")
  end

  @authorize scopes: [
               "GP",
               "NURSE",
               "EXTERNAL",
               {"EXTERNAL", "GOLD"},
               {"EXTERNAL", "PLATINUM"}
             ]
  def stats(conn, _) do
    specialist_id = conn.assigns.current_specialist_id
    team_id = Teams.specialist_team_id(specialist_id)

    stats = EncountersStats.get_for_team(team_id)

    conn
    |> render("stats.proto", stats)
  end

  @authorize scopes: [
               "GP",
               "NURSE",
               "EXTERNAL",
               {"EXTERNAL", "GOLD"},
               {"EXTERNAL", "PLATINUM"}
             ]
  def invitations(conn, _) do
    specialist_id = conn.assigns.current_specialist_id

    teams = Teams.get_invitations(specialist_id)

    profiles =
      teams
      |> Enum.map(& &1.owner_id)
      |> Web.SpecialistGenericData.get_by_ids()

    render(conn, "team_invitations.proto", teams: teams, owner_profiles: profiles)
  end

  @authorize scopes: [
               "GP",
               "NURSE",
               "EXTERNAL",
               {"EXTERNAL", "GOLD"},
               {"EXTERNAL", "PLATINUM"}
             ]
  def accept_invitation(conn, %{"team_id" => team_id}) do
    specialist_id = conn.assigns.current_specialist_id

    with :ok <- Teams.accept_invitation(team_id: team_id, specialist_id: specialist_id) do
      send_resp(conn, 200, "")
    end
  end

  @authorize scopes: [
               "GP",
               "NURSE",
               "EXTERNAL",
               {"EXTERNAL", "GOLD"},
               {"EXTERNAL", "PLATINUM"}
             ]
  def decline_invitation(conn, %{"team_id" => team_id}) do
    specialist_id = conn.assigns.current_specialist_id

    with :ok <- Teams.decline_invitation(team_id: team_id, specialist_id: specialist_id) do
      send_resp(conn, 200, "")
    end
  end

  @authorize scopes: [
               "GP",
               "NURSE",
               "EXTERNAL",
               {"EXTERNAL", "GOLD"},
               {"EXTERNAL", "PLATINUM"}
             ]
  def urgent_care_stats(conn, _) do
    specialist_id = conn.assigns.current_specialist_id
    team_id = Teams.specialist_team_id(specialist_id)

    stats = EncountersStats.get_urgent_care_stats_for_team(team_id)

    conn
    |> render("urgent_care_stats.proto", stats)
  end

  defp get_specialist(protobuf) do
    email = protobuf.specialist_email
    account_type = protobuf.account_type

    case Authentication.Specialist.fetch_by_email(email) do
      {:ok, specialist} ->
        specialist

      {:error, :not_found} ->
        {:ok, _account} = Admin.add_specialist_to_team(%{email: email, type: account_type})
        {:ok, specialist} = Authentication.Specialist.fetch_by_email(email)
        specialist
    end
  end
end
