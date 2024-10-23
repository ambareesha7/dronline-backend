defmodule Postgres.Repo.Migrations.AddVitalsToTimeline do
  use Ecto.Migration

  def change do
    alter table(:timeline_items) do
      add :vitals_id, references("vitals"), null: true
    end

    create index(:timeline_items, [:vitals_id])
  end
end
