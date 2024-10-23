defmodule Postgres.Repo.Migrations.RemoveReferencesFromSpecialistPatientConnections do
  use Ecto.Migration

  def change do
    execute "ALTER TABLE specialist_patient_connections DROP CONSTRAINT specialist_patient_connections_patient_id_fkey"

    execute "ALTER TABLE specialist_patient_connections DROP CONSTRAINT specialist_patient_connections_specialist_id_fkey"
  end
end
