defmodule Postgres.Repo.Migrations.AddSpecialistLocationCoordinates do
  use Ecto.Migration

  def up do
    execute("CREATE EXTENSION IF NOT EXISTS postgis")

    alter table(:specialist_locations) do
      add :formatted_address, :string
      add :coordinates, :geometry
    end
  end

  def down do
    alter table(:specialist_locations) do
      remove :formatted_address, :string
      remove :coordinates, :geometry
    end

    execute("DROP EXTENSION IF EXISTS postgis")
  end
end
