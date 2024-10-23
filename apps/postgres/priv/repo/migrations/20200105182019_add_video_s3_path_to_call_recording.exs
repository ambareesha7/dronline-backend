defmodule Postgres.Repo.Migrations.AddVideoS3PathToCallRecording do
  use Ecto.Migration

  def change do
    alter table(:call_recordings) do
      add :video_s3_path, :string
    end
  end
end
