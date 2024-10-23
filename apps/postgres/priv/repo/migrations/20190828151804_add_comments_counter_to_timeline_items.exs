defmodule Postgres.Repo.Migrations.AddCommentsCounterToTimelineItems do
  use Ecto.Migration

  def change do
    alter table(:timeline_items) do
      add :comments_counter, :integer, default: 0
    end
  end
end
