defmodule Postgres.Repo.Migrations.RecordInvolvedSpecialists do
  use Ecto.Migration

  def change do
    create table(:records_involved_specialists, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :patient_id, :integer
      add :record_id, :integer
      add :involved_specialist_id, :integer

      timestamps()
    end

    create unique_index(:records_involved_specialists, [
             :patient_id,
             :record_id,
             :involved_specialist_id
           ])
  end
end
