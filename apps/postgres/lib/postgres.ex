defmodule Postgres do
  def migrate! do
    migrations_path = Application.app_dir(:postgres, "priv/repo/migrations")
    Ecto.Migrator.run(Postgres.Repo, migrations_path, :up, all: true)
  end
end
