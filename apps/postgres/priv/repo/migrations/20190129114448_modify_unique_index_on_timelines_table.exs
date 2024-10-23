defmodule Postgres.Repo.Migrations.ModifyUniqueIndexOnTimelinesTable do
  use Ecto.Migration

  def change do
    drop unique_index(:timelines, [:user_id], name: "current_timeline_index")

    create unique_index(:timelines, [:user_id],
             where: "active = true and type = 'AUTO'",
             name: "current_auto_timeline_index"
           )
  end
end
