defmodule Postgres.Repo.Migrations.AddCallsToTimeline do
  use Ecto.Migration

  def change do
    alter table(:timeline_items) do
      add :call_id, references("calls"), null: true
    end

    create index(:timeline_items, [:call_id])
  end
end
