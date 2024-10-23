defmodule Postgres.Repo.Migrations.AddPatientIdToVideoRecordings do
  use Ecto.Migration

  def change do
    alter table(:call_recordings) do
      add :patient_id, :bigint
    end

    create index(:call_recordings, [:patient_id])
  end
end
