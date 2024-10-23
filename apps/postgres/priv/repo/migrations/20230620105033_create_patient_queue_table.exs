defmodule Postgres.Repo.Migrations.CreatePatientQueueTable do
  use Ecto.Migration

  def change do
    create table(:patients_queue) do
      add :patient_id, :integer
      add :device_id, :string
      add :handling_team_ids, {:array, :integer}, default: []
      add :record_id, :integer

      timestamps()
    end
  end
end
