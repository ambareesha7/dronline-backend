defmodule Postgres.Repo.Migrations.AddPendingMedicalSummariesTable do
  use Ecto.Migration

  def change do
    create table(:pending_medical_summaries) do
      add :record_id, :integer
      add :specialist_id, :integer

      timestamps()
    end

    create unique_index(:pending_medical_summaries, [:record_id, :specialist_id])
  end
end
