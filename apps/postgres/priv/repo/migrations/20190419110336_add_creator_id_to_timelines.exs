defmodule Postgres.Repo.Migrations.AddCreatorIdToTimelines do
  use Ecto.Migration

  def change do
    alter table(:timelines) do
      add :creator_id, references(:specialists)
    end

    create index(:timelines, [:creator_id])
  end
end
