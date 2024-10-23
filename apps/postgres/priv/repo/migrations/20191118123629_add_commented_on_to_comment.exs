defmodule Postgres.Repo.Migrations.AddCommentedOnToComment do
  use Ecto.Migration

  def change do
    alter table("timeline_item_comments") do
      add :commented_on, :string
    end
  end
end
