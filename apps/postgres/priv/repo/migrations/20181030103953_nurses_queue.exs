defmodule Postgres.Repo.Migrations.NursesQueue do
  use Ecto.Migration

  def change do
    create table(:nurses_queue_projection) do
      add :proto, :binary
    end

    execute "INSERT INTO nurses_queue_projection DEFAULT VALUES"
  end
end
