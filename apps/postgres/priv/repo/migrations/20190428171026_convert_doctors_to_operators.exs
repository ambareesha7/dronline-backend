defmodule Postgres.Repo.Migrations.ConvertDoctorsToOperators do
  use Ecto.Migration

  def change do
    execute("UPDATE specialists SET type = 'OPERATOR' WHERE type = 'DOCTOR'")
  end
end
