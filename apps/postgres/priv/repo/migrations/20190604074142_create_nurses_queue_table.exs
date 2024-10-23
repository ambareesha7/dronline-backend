defmodule Postgres.Repo.Migrations.CreatePendingNurseToGPCallsTable do
  use Ecto.Migration

  def change do
    create table(:pending_nurse_to_gp_calls, primary_key: false) do
      add :nurse_id, references(:specialists), primary_key: true, null: false
      add :record_id, references(:timelines), null: false
      add :patient_id, references(:patients), null: false

      timestamps()
    end

    create index(:pending_nurse_to_gp_calls, :inserted_at)
  end
end
