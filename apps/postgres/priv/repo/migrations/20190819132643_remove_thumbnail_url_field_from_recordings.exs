defmodule Postgres.Repo.Migrations.RemoveThumbnailUrlFieldFromRecordings do
  use Ecto.Migration

  def change do
    alter table("call_recordings") do
      remove :thumbnail_url
    end
  end
end
