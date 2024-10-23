defmodule Postgres.Repo.Migrations.RemoveOldProjections do
  use Ecto.Migration

  def change do
    drop table(:unassigned_dispatches)
    drop table(:dispatches_in_progress)
  end
end
