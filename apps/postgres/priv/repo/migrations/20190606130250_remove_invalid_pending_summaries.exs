defmodule Postgres.Repo.Migrations.RemoveInvalidPendingSummaries do
  use Ecto.Migration

  def change do
    execute "DELETE FROM pending_medical_summaries WHERE patient_id IS NULL;"
  end
end
