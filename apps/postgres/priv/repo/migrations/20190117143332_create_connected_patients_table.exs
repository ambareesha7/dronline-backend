defmodule Postgres.Repo.Migrations.CreateConnectedPatientsTable do
  use Ecto.Migration

  def change do
    create table(:specialist_patient_connections) do
      add :specialist_id, references(:specialists)
      add :user_id, references(:users)

      timestamps()
    end

    create index(:specialist_patient_connections, [:specialist_id])
    create unique_index(:specialist_patient_connections, [:user_id, :specialist_id])
  end
end
