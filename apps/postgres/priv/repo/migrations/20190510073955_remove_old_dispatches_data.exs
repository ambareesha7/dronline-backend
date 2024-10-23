defmodule Postgres.Repo.Migrations.RemoveOldDispatchesData do
  use Ecto.Migration

  def change do
    alter table(:timeline_items) do
      remove :dispatch_id
    end

    drop table(:dispatch_requests)
    drop table(:dispatches)
    drop table(:triage_unit_states)
  end
end
