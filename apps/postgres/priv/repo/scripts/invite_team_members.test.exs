Code.require_file("priv/repo/scripts/invite_team_members.exs")

ExUnit.start()

defmodule Postgres.Scripts.InviteTeamMembersTest do
  use ExUnit.Case

  test "invite given emails to owner's team" do
    owner = Authentication.Factory.insert(:specialist)
    specialist1 = Authentication.Factory.insert(:specialist)
    specialist2 = Authentication.Factory.insert(:specialist)
    specialist3 = Authentication.Factory.insert(:specialist)

    {:ok, team} = Teams.create_team(owner.id, %{})

    Postgres.Scripts.InviteTeamMembers.invite_team_members(owner.email, [
      specialist1.email,
      specialist2.email,
      specialist3.email
    ])

    assert Teams.specialist_team_id(owner.id) == team.id
    assert Teams.specialist_team_id(specialist1.id) == team.id
    refute Teams.is_admin?(specialist1.id)
    assert Teams.specialist_team_id(specialist2.id) == team.id
    refute Teams.is_admin?(specialist2.id)
    assert Teams.specialist_team_id(specialist3.id) == team.id
    refute Teams.is_admin?(specialist3.id)
  end
end
