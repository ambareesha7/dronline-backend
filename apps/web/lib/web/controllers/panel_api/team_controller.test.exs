defmodule Web.PanelApi.TeamControllerTest do
  use Web.ConnCase, async: true

  setup [:authenticate_gp, :proto_content]

  alias Proto.Teams.AddMember
  alias Proto.Teams.MyTeam
  alias Proto.Teams.SetBranding
  alias Proto.Teams.SetRole
  alias Proto.Teams.SetTeamLocation
  alias Proto.Teams.TeamEncountersStatsResponse
  alias Proto.Teams.TeamInvitations
  alias Proto.Teams.TeamMembersResponse
  alias Proto.Teams.TeamUrgentCareStatsResponse

  test "GET /my_team returns the team_id", %{conn: conn, current_gp: gp} do
    {:ok, %{id: team_id}} = Teams.create_team(random_id(), %{})
    :ok = add_to_team(team_id: team_id, specialist_id: gp.id)

    resp = get(conn, "/panel_api/my_team")

    assert %{team_id: ^team_id} = proto_response(resp, 200, MyTeam)
  end

  test "GET /team_invitations returns the list of invitations", %{conn: conn, current_gp: gp} do
    specialist = Authentication.Factory.insert(:verified_and_approved_external)
    _basic_info = SpecialistProfile.Factory.insert(:basic_info, specialist_id: specialist.id)
    _location = SpecialistProfile.Factory.insert(:location, specialist_id: specialist.id)

    {:ok, %{id: team_id}} = Teams.create_team(specialist.id, %{})

    :ok = Teams.add_to_team(team_id: team_id, specialist_id: gp.id)

    resp = get(conn, "/panel_api/team_invitations")

    assert %TeamInvitations{invitations: [%{team_id: ^team_id}]} =
             proto_response(resp, 200, TeamInvitations)

    put(conn, "/panel_api/team_invitations/#{team_id}/accept", %{})

    assert Teams.specialist_team_id(gp.id) == team_id
  end

  test "invitations can be declined", %{conn: conn, current_gp: gp} do
    specialist = Authentication.Factory.insert(:verified_and_approved_external)
    _basic_info = SpecialistProfile.Factory.insert(:basic_info, specialist_id: specialist.id)
    _location = SpecialistProfile.Factory.insert(:location, specialist_id: specialist.id)

    {:ok, %{id: team_id}} = Teams.create_team(specialist.id, %{})

    :ok = Teams.add_to_team(team_id: team_id, specialist_id: gp.id)

    put(conn, "/panel_api/team_invitations/#{team_id}/decline", %{})

    resp = get(conn, "/panel_api/team_invitations")

    assert %TeamInvitations{invitations: []} = proto_response(resp, 200, TeamInvitations)
  end

  test "GET /my_team/members returns the list of profiles", %{conn: conn, current_gp: gp} do
    {:ok, %{id: team_id}} = Teams.create_team(random_id(), %{})
    :ok = add_to_team(team_id: team_id, specialist_id: gp.id)

    patient = PatientProfile.Factory.insert(:patient)

    _completed_record =
      EMR.Factory.insert(
        :completed_record,
        patient_id: patient.id,
        specialist_id: gp.id,
        type: :AUTO
      )

    resp = get(conn, "/panel_api/my_team/members")

    assert %{
             team_members: [
               %{
                 profile: _,
                 member_role: _,
                 encounters_stats: %{
                   scheduled: 0,
                   pending: 0,
                   completed: 1,
                   canceled: 0
                 }
               }
             ]
           } = proto_response(resp, 200, TeamMembersResponse)
  end

  test "POST /my_team/members adds a specialist to a team", %{conn: conn, current_gp: gp} do
    owner = Authentication.Factory.insert(:verified_and_approved_external)
    {:ok, %{id: team_id}} = Teams.create_team(owner.id, %{})
    :ok = add_to_team(team_id: team_id, specialist_id: gp.id)

    specialist = Authentication.Factory.insert(:verified_and_approved_external)

    req = %AddMember{specialist_email: specialist.email} |> AddMember.encode()

    resp = post(conn, "/panel_api/my_team/members", req)
    :ok = Teams.accept_invitation(team_id: team_id, specialist_id: specialist.id)

    assert resp.status == 200

    assert [_owner, _gp, _specialist] = Teams.get_members(team_id)
  end

  test "POST /my_team/members creates an account if it doesn't exist yet", %{
    conn: conn,
    current_gp: gp
  } do
    {:ok, %{id: team_id}} = Teams.create_team(random_id(), %{})
    :ok = add_to_team(team_id: team_id, specialist_id: gp.id)

    email = "specialist@example.com"

    req = %AddMember{specialist_email: email, account_type: 1} |> AddMember.encode()

    resp = post(conn, "/panel_api/my_team/members", req)

    assert resp.status == 200

    assert Authentication.Specialist.fetch_by_email(email)
  end

  test "PUT /my_team/members/:specialist_id/role sets the role", %{conn: conn, current_gp: gp} do
    {:ok, %{id: team_id}} = Teams.create_team(gp.id, %{})

    specialist = Authentication.Factory.insert(:verified_and_approved_external)
    :ok = add_to_team(team_id: team_id, specialist_id: specialist.id)

    req = %SetRole{new_role: 2} |> SetRole.encode()

    resp = put(conn, "/panel_api/my_team/members/#{specialist.id}/role", req)
    assert resp.status == 200

    role =
      team_id
      |> Teams.get_members()
      |> Enum.find(&(&1.specialist_id == specialist.id))
      |> Map.get(:role)

    assert role == "admin"
  end

  test "DELETE /my_team/members/:specialist_id removes a specialist from a team", %{
    conn: conn,
    current_gp: gp
  } do
    {:ok, %{id: team_id}} = Teams.create_team(random_id(), %{})
    :ok = add_to_team(team_id: team_id, specialist_id: gp.id)

    specialist = Authentication.Factory.insert(:verified_and_approved_external)

    :ok = add_to_team(team_id: team_id, specialist_id: specialist.id)

    resp = delete(conn, "/panel_api/my_team/members/#{specialist.id}")
    assert resp.status == 200

    assert [_owner, _gp] = Teams.get_members(team_id)
  end

  test "POST /my_team creates a new team or returns existing one", %{conn: conn, current_gp: gp} do
    resp = post(conn, "/panel_api/my_team")

    assert %{team_id: team_id} = proto_response(resp, 200, MyTeam)
    assert Teams.specialist_team_id(gp.id) == team_id

    second_resp = post(conn, "/panel_api/my_team")

    assert %{team_id: ^team_id} = proto_response(second_resp, 200, MyTeam)
  end

  test "PUT /my_team/branding lets you set the name and logo_url", %{conn: conn, current_gp: gp} do
    {:ok, _} = Teams.create_team(gp.id, %{})

    payload =
      %SetBranding{
        name: "Test",
        logo_url: "test_url"
      }
      |> SetBranding.encode()

    resp = put(conn, "/panel_api/my_team/branding", payload)

    assert resp.status == 200

    get_resp = get(conn, "/panel_api/my_team")

    assert %{name: "Test"} = proto_response(get_resp, 200, MyTeam)
  end

  test "PUT /my_team/location lets you set the team's location", %{conn: conn, current_gp: gp} do
    {:ok, %{id: team_id}} = Teams.create_team(random_id(), %{})
    :ok = add_to_team(team_id: team_id, specialist_id: gp.id)

    lat = 10.0
    lon = 5.0

    payload =
      %SetTeamLocation{
        location: %Proto.Generics.Coordinates{
          lat: lat,
          lon: lon
        },
        formatted_address: "Address"
      }
      |> SetTeamLocation.encode()

    resp = put(conn, "/panel_api/my_team/location", payload)

    assert resp.status == 200

    get_resp = get(conn, "/panel_api/my_team")

    assert %{team_id: ^team_id, location: %{lat: ^lat, lon: ^lon}, formatted_address: "Address"} =
             proto_response(get_resp, 200, MyTeam)
  end

  test "GET /my_team/stats returns the number of encounters", %{conn: conn, current_gp: gp} do
    {:ok, %{id: team_id}} = Teams.create_team(random_id(), %{})
    :ok = add_to_team(team_id: team_id, specialist_id: gp.id)

    specialist = Authentication.Factory.insert(:verified_and_approved_external)
    :ok = add_to_team(team_id: team_id, specialist_id: specialist.id)

    patient = PatientProfile.Factory.insert(:patient)

    _completed_record =
      EMR.Factory.insert(
        :completed_record,
        patient_id: patient.id,
        specialist_id: specialist.id,
        type: :AUTO
      )

    resp = get(conn, "/panel_api/my_team/stats")

    assert %{
             scheduled: 0,
             pending: 0,
             canceled: 0,
             completed: 1
           } = proto_response(resp, 200, TeamEncountersStatsResponse)
  end

  test "GET /my_team/urgent_care_stats returns the stats", %{conn: conn, current_gp: gp} do
    {:ok, %{id: team_id}} = Teams.create_team(gp.id, %{})
    :ok = add_to_team(team_id: team_id, specialist_id: gp.id)

    patient = PatientProfile.Factory.insert(:patient)

    _urgent_care_record =
      EMR.Factory.insert(
        :completed_record,
        patient_id: patient.id,
        specialist_id: gp.id,
        type: :AUTO
      )

    resp = get(conn, "/panel_api/my_team/urgent_care_stats")

    assert %{
             total: 1
           } = proto_response(resp, 200, TeamUrgentCareStatsResponse)
  end

  defp random_id, do: :rand.uniform(1000)

  defp add_to_team(opts) do
    :ok = Teams.add_to_team(opts)
    Teams.accept_invitation(opts)
  end
end
