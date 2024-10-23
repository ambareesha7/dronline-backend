defmodule Postgres.Repo.Migrations.AddPatientsRelationship do
  use Ecto.Migration

  def change do
    create table(:patients_family_relationship, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :parent_patient_id, :bigint, null: false
      add :child_patient_id, :bigint, null: false

      timestamps()
    end

    create unique_index(:patients_family_relationship, [:parent_patient_id, :child_patient_id])
    create index(:patients_family_relationship, [:child_patient_id])
  end
end
