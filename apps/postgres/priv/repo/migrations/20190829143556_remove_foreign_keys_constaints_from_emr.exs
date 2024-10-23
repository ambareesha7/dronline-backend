defmodule Postgres.Repo.Migrations.RemoveForeignKeysConstaintsFromEmr do
  use Ecto.Migration

  def change do
    execute "ALTER TABLE calls DROP CONSTRAINT calls_medical_category_id_fkey"
    execute "ALTER TABLE calls DROP CONSTRAINT calls_patient_id_fkey"
    execute "ALTER TABLE calls DROP CONSTRAINT calls_specialist_id_fkey"
    execute "ALTER TABLE calls DROP CONSTRAINT calls_timeline_id_fkey"

    execute "ALTER TABLE doctor_invitations DROP CONSTRAINT doctor_invitations_medical_category_id_fkey"
    execute "ALTER TABLE doctor_invitations DROP CONSTRAINT doctor_invitations_patient_id_fkey"
    execute "ALTER TABLE doctor_invitations DROP CONSTRAINT doctor_invitations_specialist_id_fkey"
    execute "ALTER TABLE doctor_invitations DROP CONSTRAINT doctor_invitations_timeline_id_fkey"

    execute "ALTER TABLE timeline_items DROP CONSTRAINT timeline_items_timeline_id_fkey"
  end
end
