defmodule Postgres.Repo.Migrations.AddTeamIdToCanceledAndEndedVisits do
  use Ecto.Migration

  def change do
    alter table(:canceled_visits) do
      add :team_id, :integer
    end

    alter table(:ended_visits) do
      add :team_id, :integer
    end

    create(index(:canceled_visits, :team_id))
    create(index(:ended_visits, :team_id))
  end
end
