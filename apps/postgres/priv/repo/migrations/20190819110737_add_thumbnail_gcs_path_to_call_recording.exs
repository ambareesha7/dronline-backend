defmodule Postgres.Repo.Migrations.AddThumbnailGcsPathToCallRecording do
  use Ecto.Migration

  def change do
    alter table("call_recordings") do
      add :thumbnail_gcs_path, :string
    end
  end
end
