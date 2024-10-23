defmodule Postgres.Repo.Migrations.AlterPatientsQueueProjectionTable do
  use Ecto.Migration

  def change do
    alter table(:patients_queue_projection) do
      remove :proto
      add :patient_ids_in_queue, {:array, :integer}, default: []
    end
  end
end
