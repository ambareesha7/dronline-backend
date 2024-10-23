defmodule Postgres.Repo.Migrations.CreateTimelinesTable do
  use Ecto.Migration

  def change do
    create table(:timelines) do
      add :active, :boolean, default: true
      add :user_id, references("users"), null: false

      timestamps()
    end

    create index(:timelines, [:active, :user_id])

    create unique_index(:timelines, [:active],
             where: "active = true",
             name: "current_timeline_index"
           )
  end
end
