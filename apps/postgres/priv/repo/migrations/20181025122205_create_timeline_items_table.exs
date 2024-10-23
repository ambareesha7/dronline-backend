defmodule Postgres.Repo.Migrations.CreateTimelineItemsTable do
  use Ecto.Migration

  def change do
    create table(:timeline_items) do
      add :timeline_id, references("timelines"), null: false

      timestamps()
    end

    create index(:timeline_items, [:timeline_id])
  end
end
