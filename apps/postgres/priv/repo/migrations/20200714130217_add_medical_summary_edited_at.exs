defmodule Postgres.Repo.Migrations.AddMedicalSummaryEditedAt do
  use Ecto.Migration

  def change do
    alter table(:medical_summaries) do
      add :edited_at, :naive_datetime
    end
  end
end
