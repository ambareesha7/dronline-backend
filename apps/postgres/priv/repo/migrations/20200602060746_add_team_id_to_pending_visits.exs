defmodule Postgres.Repo.Migrations.AddTeamIdToPendingVisits do
  use Ecto.Migration

  def change do
    alter(table(:pending_visits)) do
      add(:team_id, :integer)
    end

    create(index(:pending_visits, :team_id))
  end
end
