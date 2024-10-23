defmodule Postgres.Repo.Migrations.PendingVisits do
  use Ecto.Migration

  def change do
    create table(:pending_visits, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :start_time, :bigint

      add :patient_id, :bigint
      add :record_id, :bigint
      add :specialist_id, :bigint

      timestamps()
    end

    create index(:pending_visits, [:patient_id])
    create index(:pending_visits, [:specialist_id])
  end
end
