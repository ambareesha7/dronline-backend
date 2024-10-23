defmodule Postgres.Repo.Migrations.RemoveChildrenTables do
  use Ecto.Migration

  def change do
    drop table(:child_bmis)
    drop table(:child_history_forms)
    drop table(:children)
  end
end
