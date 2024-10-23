defmodule Postgres.Repo.Migrations.Refactor do
  use Ecto.Migration

  def change do
    rename table(:triage_unit_state_projection), to: table(:triage_unit_states)
  end
end
