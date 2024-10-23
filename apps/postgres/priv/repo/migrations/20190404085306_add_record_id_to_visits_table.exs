defmodule Postgres.Repo.Migrations.AddRecordIdToVisitsTable do
  use Ecto.Migration

  def change do
    alter table(:visits) do
      add :record_id, references(:timelines)
    end

    create index(:visits, [:record_id])
  end
end
