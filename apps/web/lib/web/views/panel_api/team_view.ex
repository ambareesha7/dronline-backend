defmodule Web.PanelApi.TeamView do
  use Web, :view

  def render("show.proto", %{
        team_id: team_id,
        location: location,
        formatted_address: formatted_address,
        is_admin: is_admin,
        is_owner: is_owner,
        name: name,
        logo_url: logo_url
      }) do
    %Proto.Teams.MyTeam{
      team_id: team_id,
      location: %Proto.Generics.Coordinates{lat: location[:latitude], lon: location[:longitude]},
      formatted_address: formatted_address,
      is_current_user_admin: is_admin,
      is_current_user_owner: is_owner,
      name: name,
      logo_url: logo_url
    }
  end

  def render("members.proto", %{member_profiles: profiles}) do
    %Proto.Teams.TeamMembersResponse{
      team_members:
        Enum.map(profiles, fn {member, profile, encounters_stats} ->
          %Proto.Teams.TeamMember{
            profile: Web.View.Generics.render_specialist(profile),
            member_role: role(member.role),
            encounters_stats: render("stats.proto", encounters_stats)
          }
        end)
    }
  end

  def render("team_invitations.proto", %{teams: teams, owner_profiles: profiles}) do
    %Proto.Teams.TeamInvitations{
      invitations:
        Enum.map(teams, fn team ->
          %Proto.Teams.TeamInvitation{
            team_id: team.id,
            owner_profile:
              Web.View.Generics.render_specialist(
                Enum.find(profiles, &(&1.basic_info.specialist_id == team.owner_id))
              )
          }
        end)
    }
  end

  def render("stats.proto", %{
        scheduled: scheduled,
        pending: pending,
        canceled: canceled,
        completed: completed
      }) do
    %Proto.Teams.TeamEncountersStatsResponse{
      scheduled: scheduled,
      pending: pending,
      canceled: canceled,
      completed: completed
    }
  end

  def render("urgent_care_stats.proto", %{
        total: total
      }) do
    %Proto.Teams.TeamUrgentCareStatsResponse{
      total: total
    }
  end

  defp role("admin"), do: 2
  defp role(_), do: 1
end
