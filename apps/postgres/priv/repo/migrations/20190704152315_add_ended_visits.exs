defmodule Postgres.Repo.Migrations.AddEndedVisits do
  use Ecto.Migration

  def change do
    create table(:ended_visits, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :start_time, :bigint

      add :chosen_medical_category_id, :bigint
      add :patient_id, :bigint
      add :record_id, :bigint
      add :specialist_id, :bigint

      timestamps()
    end

    create index(:ended_visits, [:patient_id])
    create index(:ended_visits, [:specialist_id])
  end
end
