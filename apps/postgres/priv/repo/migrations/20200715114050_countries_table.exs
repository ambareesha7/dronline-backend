defmodule Postgres.Repo.Migrations.CountriesTable do
  use Ecto.Migration

  def change do
    create table(:countries, primary_key: false) do
      add :id, :string, null: false, primary_key: true
      add :name, :string, null: false
      add :dial_code, :string, null: false
    end

    create unique_index(:countries, [:name])
  end
end
