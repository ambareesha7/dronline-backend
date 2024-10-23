defmodule Postgres.Repo.Migrations.TriageUnitStatusFieldChange do
  use Ecto.Migration

  def change do
    rename table(:triage_unit_state_projection), :ready, to: :available
  end
end
