defmodule Postgres.Repo.Migrations.AddIndexOnInsertedAtInHpisTable do
  use Ecto.Migration

  def change do
    create index(:hpis, [:inserted_at])
  end
end
