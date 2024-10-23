defmodule Postgres.Repo.Migrations.AddTeamIdToSpecialistPatientConnections do
  use Ecto.Migration

  def change do
    alter(table(:specialist_patient_connections)) do
      add(:team_id, :integer)
    end

    create(index(:specialist_patient_connections, :team_id))
  end
end
