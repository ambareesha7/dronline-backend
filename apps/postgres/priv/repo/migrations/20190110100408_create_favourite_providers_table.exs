defmodule Postgres.Repo.Migrations.CreateFavouriteProvidersTable do
  use Ecto.Migration

  def change do
    create table(:favourite_providers) do
      add :user_id, references(:users)
      add :specialist_id, references(:specialists)

      timestamps()
    end

    create index(:favourite_providers, [:user_id])
    create index(:favourite_providers, [:specialist_id])
    create unique_index(:favourite_providers, [:user_id, :specialist_id])
  end
end
