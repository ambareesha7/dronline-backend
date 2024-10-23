defmodule Postgres.Repo.Migrations.FixUniqueIndexOnTimelines do
  use Ecto.Migration

  def change do
    drop unique_index(:timelines, [:active],
           where: "active = true",
           name: "current_timeline_index"
         )

    create unique_index(:timelines, [:user_id],
             where: "active = true",
             name: "current_timeline_index"
           )
  end
end
