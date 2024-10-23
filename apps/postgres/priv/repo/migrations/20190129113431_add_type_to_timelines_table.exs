defmodule Postgres.Repo.Migrations.AddTypeToTimelinesTable do
  use Ecto.Migration

  def change do
    alter table(:timelines) do
      add :type, :string, default: "AUTO", null: false
    end

    create index(:timelines, [:type])
  end
end
