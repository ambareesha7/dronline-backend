defmodule Postgres.Repo.Migrations.DropUserHpisTable do
  use Ecto.Migration

  def change do
    drop table(:user_hpis)
  end
end
