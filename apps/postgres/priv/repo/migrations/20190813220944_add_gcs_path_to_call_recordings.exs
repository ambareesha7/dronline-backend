defmodule Postgres.Repo.Migrations.AddGcsPathToCallRecordings do
  use Ecto.Migration

  def change do
    alter table("call_recordings") do
      add :video_gcs_path, :string
    end
  end
end
