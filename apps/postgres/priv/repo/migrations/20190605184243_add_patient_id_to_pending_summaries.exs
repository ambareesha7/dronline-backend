defmodule Postgres.Repo.Migrations.AddPatientIdToPendingSummaries do
  use Ecto.Migration

  def change do
    alter table(:pending_medical_summaries) do
      add :patient_id, :bigint
      modify :record_id, :bigint, from: :integer
      modify :specialist_id, :bigint, from: :integer
    end
  end
end
