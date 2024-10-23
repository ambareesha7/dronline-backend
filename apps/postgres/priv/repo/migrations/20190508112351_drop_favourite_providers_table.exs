defmodule Postgres.Repo.Migrations.DropFavouriteProvidersTable do
  use Ecto.Migration

  def change do
    drop table(:favourite_providers)
  end
end
