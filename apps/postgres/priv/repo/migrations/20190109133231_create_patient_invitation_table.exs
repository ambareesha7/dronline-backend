defmodule Postgres.Repo.Migrations.CreatePatientInvitationTable do
  use Ecto.Migration

  def change do
    create table(:patient_invitations) do
      add :phone_number, :string
      add :specialist_id, references(:specialists)

      timestamps()
    end

    create index(:patient_invitations, [:specialist_id])
    create unique_index(:patient_invitations, [:phone_number, :specialist_id])
  end
end
