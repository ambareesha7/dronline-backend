defmodule Postgres.Repo.Migrations.AddRoleToTeamMembers do
  use Ecto.Migration

  def change do
    alter(table(:specialist_team_members)) do
      add :role, :string
    end
  end
end
