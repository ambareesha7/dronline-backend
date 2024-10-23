defmodule Postgres.Repo.Migrations.AddMedicalMedications do
  use Ecto.Migration

  def up do
    create table(:medical_medications) do
      add :name, :string, null: false
    end

    create unique_index(:medical_medications, [:name])

    execute("""
      CREATE INDEX medical_medications_trgm_idx ON medical_medications 
        USING GIN (
          name gin_trgm_ops
        )
    """)

    create table(:medications_bundles) do
      add :timeline_id, :bigint, null: false
      add :specialist_id, :bigint, null: false
      add :patient_id, :bigint, null: false

      add :medications,
          :jsonb,
          null: false,
          default: "[]"

      timestamps()
    end

    create index(:medications_bundles, [:timeline_id])

    alter table(:timeline_items) do
      add :medications_bundle_id, :bigint
    end
  end

  def down do
    drop table(:medical_medications)
    drop table(:medications_bundles)

    alter table(:timeline_items) do
      remove :medications_bundle_id
    end
  end
end
