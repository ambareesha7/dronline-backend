defmodule Postgres.Repo.Migrations.UsersQueueProjection do
  use Ecto.Migration

  def change do
    create table(:users_queue_projection) do
      add :proto, :binary
    end

    execute "INSERT INTO users_queue_projection DEFAULT VALUES"
  end
end
