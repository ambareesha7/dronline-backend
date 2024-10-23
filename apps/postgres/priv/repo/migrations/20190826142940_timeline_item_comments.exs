defmodule Postgres.Repo.Migrations.TimelineItemComments do
  use Ecto.Migration

  def change do
    create table(:timeline_item_comments, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :patient_id, :bigint
      add :record_id, :bigint
      add :timeline_item_id, :binary_id

      add :commented_by_specialist_id, :bigint

      add :body, :text

      timestamps()
    end

    create index(:timeline_item_comments, [:patient_id])
    create index(:timeline_item_comments, [:record_id])
    create index(:timeline_item_comments, [:timeline_item_id])
    create index(:timeline_item_comments, [:inserted_at])
  end
end
