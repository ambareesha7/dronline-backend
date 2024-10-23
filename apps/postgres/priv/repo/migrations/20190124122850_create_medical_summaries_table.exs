defmodule Postgres.Repo.Migrations.CreateMedicalSummariesTable do
  use Ecto.Migration

  def change do
    create table(:medical_summaries) do
      add :timeline_id, references(:timelines)
      add :specialist_id, references(:specialists)
      add :data, :binary

      timestamps()
    end

    create index(:medical_summaries, [:timeline_id])
    create index(:medical_summaries, [:specialist_id])
  end
end
