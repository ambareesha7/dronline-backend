defmodule Postgres.Repo.Migrations.CreateDevicesTables do
  use Ecto.Migration

  def change do
    create table(:patient_devices) do
      add :token, :string, null: false
      add :patient_id, references(:patients), null: false

      timestamps()
    end

    create index(:patient_devices, :patient_id)
    create unique_index(:patient_devices, :token)

    create table(:specialist_devices) do
      add :token, :string, null: false
      add :specialist_id, references(:specialists), null: false

      timestamps()
    end

    create index(:specialist_devices, :specialist_id)
    create unique_index(:specialist_devices, :token)
  end
end
