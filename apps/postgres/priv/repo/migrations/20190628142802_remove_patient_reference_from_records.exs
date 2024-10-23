defmodule Postgres.Repo.Migrations.RemovePatientReferenceFromRecords do
  use Ecto.Migration

  def change do
    execute "ALTER TABLE timelines DROP CONSTRAINT timelines_patient_id_fkey"
    create index(:timelines, [:patient_id])
  end
end
