defmodule Postgres.Repo.Migrations.RecordSessionIds do
  use Ecto.Migration

  def change do
    create table(:record_tokbox_sessions, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :record_id, :bigint
      add :tokbox_session_id, :string

      timestamps()
    end

    create unique_index(:record_tokbox_sessions, [:tokbox_session_id])
  end
end
