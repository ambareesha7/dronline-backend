defmodule Postgres.Repo.Migrations.RemoveForeignKeyConstraintsFromDevices do
  use Ecto.Migration

  def change do
    execute "ALTER TABLE patient_devices DROP CONSTRAINT patient_devices_patient_id_fkey"

    execute "ALTER TABLE specialist_devices DROP CONSTRAINT specialist_devices_specialist_id_fkey"

    execute "ALTER TABLE patient_ios_devices DROP CONSTRAINT patient_ios_devices_patient_id_fkey"

    execute "ALTER TABLE specialist_ios_devices DROP CONSTRAINT specialist_ios_devices_specialist_id_fkey"
  end
end
