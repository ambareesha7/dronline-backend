defmodule Postgres.Repo.Migrations.AddTimelineIdToDispatches do
  use Ecto.Migration

  def change do
    alter table(:dispatches) do
      add :timeline_id, references(:timelines), null: false
    end
  end
end
