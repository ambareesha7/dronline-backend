defmodule Postgres.Repo.Migrations.AddFieldsToSpecialistLocations do
  use Ecto.Migration

  def change do
    alter table(:specialist_locations) do
      add :additional_numbers, :string
      add :neighborhood, :string
    end
  end
end
