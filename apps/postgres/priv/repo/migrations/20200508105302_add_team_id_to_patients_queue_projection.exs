defmodule Postgres.Repo.Migrations.AddTeamIdToPatientsQueueProjection do
  use Ecto.Migration

  def change do
    alter table(:patients_queue_projection) do
      add :handling_team_id, :integer
    end

    create(index(:patients_queue_projection, :handling_team_id))
  end
end
