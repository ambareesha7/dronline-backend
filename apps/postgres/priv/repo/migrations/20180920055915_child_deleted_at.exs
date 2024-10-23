defmodule Postgres.Repo.Migrations.ChildDeletedAt do
  use Ecto.Migration

  def change do
    alter table(:children) do
      add :deleted_at, :naive_datetime_usec
    end

    create index(:children, [:deleted_at])
  end
end
