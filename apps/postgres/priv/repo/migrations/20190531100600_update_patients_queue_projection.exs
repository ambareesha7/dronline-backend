defmodule Postgres.Repo.Migrations.UpdatePatientsQueueProjection do
  use Ecto.Migration

  def change do
    execute("DELETE FROM patients_queue_projection")

    alter table(:patients_queue_projection) do
      remove :patient_ids_in_queue
      add :patient_id, :integer
      add :record_id, :integer

      timestamps()
    end

    create index(:patients_queue_projection, [:patient_id])
    create index(:patients_queue_projection, [:inserted_at])
  end
end
