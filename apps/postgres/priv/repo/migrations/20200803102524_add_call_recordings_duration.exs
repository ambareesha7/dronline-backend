defmodule Postgres.Repo.Migrations.AddCallRecordingsDuration do
  use Ecto.Migration

  def change do
    alter table(:call_recordings) do
      add :duration, :integer
      add :created_at, :integer
    end
  end
end
