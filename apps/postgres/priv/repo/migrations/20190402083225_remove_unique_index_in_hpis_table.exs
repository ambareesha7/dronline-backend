defmodule Postgres.Repo.Migrations.RemoveUniqueIndexInHpisTable do
  use Ecto.Migration

  def change do
    drop unique_index(:hpis, ["timeline_id"])
  end
end
