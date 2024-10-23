defmodule Postgres.Repo.Migrations.AddDispatchesToTimeline do
  use Ecto.Migration

  def change do
    alter table(:timeline_items) do
      add :dispatch_id, references("dispatch_requests"), null: true
    end

    create index(:timeline_items, [:dispatch_id])
  end
end
