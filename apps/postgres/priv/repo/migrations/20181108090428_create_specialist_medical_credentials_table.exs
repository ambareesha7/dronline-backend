defmodule Postgres.Repo.Migrations.CreateSpecialistMedicalCredentialsTable do
  use Ecto.Migration

  def change do
    create table(:specialist_medical_credentials) do
      add :dea_number_url, :string
      add :dea_number_expiry_date, :date
      add :board_certification_url, :string
      add :board_certification_expiry_date, :date
      add :current_state_license_number_url, :string
      add :current_state_license_number_expiry_date, :date
      add :specialist_id, references(:specialists), null: false

      timestamps()
    end

    create index(:specialist_medical_credentials, [:specialist_id])
  end
end
