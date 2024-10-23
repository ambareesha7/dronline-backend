defmodule Postgres.Repo.Migrations.CreateCallRecordingsTable do
  use Ecto.Migration

  def change do
    create table(:call_recordings) do
      add :video_url, :string
      add :thumbnail_url, :string
      add :session_id, :string

      add :record_id, :bigint

      timestamps()
    end

    create index(:call_recordings, [:record_id])

    alter table(:timeline_items) do
      add :call_recording_id, references(:call_recordings)
    end

    create index(:timeline_items, [:call_recording_id])
  end
end
