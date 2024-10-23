defmodule Postgres.Repo.Migrations.CreateTeamsAndTeamMembers do
  use Ecto.Migration

  def change do
    create table(:specialist_teams) do
      add(:location, :geometry)

      timestamps()
    end

    execute("CREATE INDEX location_index on specialist_teams USING gist (location)")

    create table(:specialist_team_members) do
      add :team_id, references(:specialist_teams), null: false
      add :specialist_id, :integer, null: false

      timestamps()
    end

    create(unique_index(:specialist_team_members, [:team_id, :specialist_id]))
    create(unique_index(:specialist_team_members, [:specialist_id]))
  end
end
