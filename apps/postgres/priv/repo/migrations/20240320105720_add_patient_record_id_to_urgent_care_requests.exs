defmodule Postgres.Repo.Migrations.AddPatientRecordIdToUrgentCareRequests do
  use Ecto.Migration

  def change do
    alter table(:urgent_care_requests) do
      add :patient_record_id, references(:timelines, on_delete: :nothing)
    end

    create index(:urgent_care_requests, [:patient_record_id])
  end
end
