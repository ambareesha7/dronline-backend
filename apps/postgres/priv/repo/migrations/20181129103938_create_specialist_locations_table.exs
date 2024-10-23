defmodule Postgres.Repo.Migrations.CreateSpecialistLocationsTable do
  use Ecto.Migration

  def change do
    create table(:specialist_locations) do
      add :street, :string
      add :number, :string
      add :phone_number, :string
      add :postal_code, :string
      add :city, :string
      add :country, :string

      add :specialist_id, references(:specialists)

      timestamps()
    end

    create index(:specialist_locations, [:specialist_id])
  end
end
