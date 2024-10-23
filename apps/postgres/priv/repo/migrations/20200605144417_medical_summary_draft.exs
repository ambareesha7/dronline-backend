defmodule Postgres.Repo.Migrations.MedicalSummaryDraft do
  use Ecto.Migration

  def change do
    alter table(:medical_summaries) do
      add :is_draft, :boolean, default: false
    end
  end
end
