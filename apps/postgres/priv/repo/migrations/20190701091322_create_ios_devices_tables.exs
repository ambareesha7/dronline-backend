defmodule Postgres.Repo.Migrations.CreateIosDevicesTables do
  use Ecto.Migration

  def change do
    create table(:patient_ios_devices) do
      add :device_token, :string, null: false
      add :patient_id, references(:patients), null: false

      timestamps()
    end

    create index(:patient_ios_devices, :patient_id)
    create unique_index(:patient_ios_devices, :device_token)

    create table(:specialist_ios_devices) do
      add :device_token, :string, null: false
      add :specialist_id, references(:specialists), null: false

      timestamps()
    end

    create index(:specialist_ios_devices, :specialist_id)
    create unique_index(:specialist_ios_devices, :device_token)
  end
end
