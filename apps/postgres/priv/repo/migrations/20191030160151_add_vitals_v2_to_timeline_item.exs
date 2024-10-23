defmodule Postgres.Repo.Migrations.AddVitalsV2ToTimelineItem do
  use Ecto.Migration

  def change do
    alter table(:timeline_items) do
      add :vitals_v2_id, :binary_id
    end
  end
end
