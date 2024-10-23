defmodule Postgres.Repo.Migrations.HpiTimelineItem do
  use Ecto.Migration

  def change do
    alter table(:timeline_items) do
      add :hpi_id, references(:hpis)
    end

    create index(:timeline_items, [:hpi_id])
  end
end
