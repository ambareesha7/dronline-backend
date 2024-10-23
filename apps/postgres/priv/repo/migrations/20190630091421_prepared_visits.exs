defmodule Postgres.Repo.Migrations.PreparedVisits do
  use Ecto.Migration

  def change do
    create table(:prepared_visits, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :start_time, :bigint

      add :patient_id, :bigint
      add :record_id, :bigint
      add :specialist_id, :bigint

      timestamps()
    end

    create index(:prepared_visits, [:patient_id])
    create index(:prepared_visits, [:specialist_id])
  end
end
