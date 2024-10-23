defmodule Postgres.Scripts.InviteTeamMembers do
  # Invite existing specialists to a team by emails
  def invite_team_members(owner_email, invite_emails) do
    {:ok, owner} = Authentication.Specialist.fetch_by_email(owner_email)
    team = Postgres.Repo.get_by(Teams.Team, %{owner_id: owner.id})

    invite_ids =
      invite_emails
      |> Enum.map(fn email ->
        {:ok, specialist} = Authentication.Specialist.fetch_by_email(email)
        specialist.id
      end)

    invite_ids
    |> Enum.each(fn id ->
      params = [team_id: team.id, specialist_id: id]
      :ok = Teams.add_to_team(params)
      Teams.accept_invitation(params)
    end)
  end
end
