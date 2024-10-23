defmodule Postgres.Repo.Migrations.DropVideoUrlField do
  use Ecto.Migration

  def change do
    alter table("call_recordings") do
      remove :video_url
    end
  end
end
