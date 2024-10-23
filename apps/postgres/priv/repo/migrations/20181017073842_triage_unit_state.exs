defmodule Postgres.Repo.Migrations.TriageUnitState do
  use Ecto.Migration

  def change do
    create table(:triage_unit_state_projection) do
      add :nurse_id, references(:specialists, on_delete: :delete_all), null: false
      add :ready, :boolean, default: false

      timestamps()
    end

    create index(:triage_unit_state_projection, [:nurse_id])
  end
end
