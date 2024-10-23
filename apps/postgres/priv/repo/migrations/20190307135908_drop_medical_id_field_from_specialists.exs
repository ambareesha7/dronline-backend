defmodule Postgres.Repo.Migrations.DropMedicalIdFieldFromSpecialists do
  use Ecto.Migration

  def change do
    alter table(:specialists) do
      remove :medical_id
    end
  end
end
