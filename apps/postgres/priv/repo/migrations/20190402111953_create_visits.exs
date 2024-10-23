defmodule Postgres.Repo.Migrations.CreateVisits do
  use Ecto.Migration

  def change do
    create table(:visits) do
      add :start_time, :integer
      add :cancelled, :boolean, default: false

      add :specialist_id, references(:specialists)
      add :user_id, references(:users)

      timestamps()
    end

    create index(:visits, [:specialist_id])
    create index(:visits, [:user_id])

    create index(:visits, [:start_time])
    create index(:visits, [:cancelled])
    create index(:visits, [:inserted_at])
  end
end
