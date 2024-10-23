defmodule Postgres.Repo.Migrations.AddTimestampsToMedications do
  use Ecto.Migration

  def change do
    alter table(:medical_medications) do
      timestamps(default: fragment("now()"))
    end
  end
end
