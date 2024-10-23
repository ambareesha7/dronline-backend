defmodule Postgres.Repo.Migrations.RenameBioToDescription do
  use Ecto.Migration

  def change do
    rename table(:specialist_bios), :bio, to: :description
  end
end
