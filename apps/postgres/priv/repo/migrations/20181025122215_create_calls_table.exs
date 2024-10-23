defmodule Postgres.Repo.Migrations.CreateCallsTable do
  use Ecto.Migration

  def change do
    create table(:calls) do
      add :user_id, references("users"), null: false
      add :specialist_id, references("specialists"), null: false
      add :timeline_id, references("timelines"), null: false

      timestamps()
    end

    create index(:calls, [:user_id])
    create index(:calls, [:specialist_id])
    create index(:calls, [:timeline_id])
  end
end
