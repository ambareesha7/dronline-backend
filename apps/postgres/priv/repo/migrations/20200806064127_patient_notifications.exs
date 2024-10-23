defmodule Postgres.Repo.Migrations.PatientNotifications do
  use Ecto.Migration

  def change do
    create table(:patient_notifications, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :for_patient_id, :integer, null: false
      add :specialist_id, :integer, null: false

      add :medical_summary_id, :integer
      add :tests_bundle_id, :integer
      add :medications_bundle_id, :integer

      add :read, :boolean, default: false, null: false

      timestamps(type: :utc_datetime_usec, updated_at: false)
    end

    create index(:patient_notifications, [:for_patient_id, :read])
  end
end
