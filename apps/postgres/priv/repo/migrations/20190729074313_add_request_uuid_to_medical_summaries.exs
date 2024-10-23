defmodule Postgres.Repo.Migrations.AddRequestUuidToMedicalSummaries do
  use Ecto.Migration

  def change do
    alter table(:medical_summaries) do
      add(:request_uuid, :string)
    end

    create(unique_index(:medical_summaries, :request_uuid))
  end
end
