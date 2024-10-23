defmodule Postgres.Repo.Migrations.AddPatientAccountDeletionsTable do
  use Ecto.Migration

  def change do
    create table(:patient_account_deletions) do
      add :patient_id, :integer
      add :status, :string

      timestamps()
    end

    create unique_index(:patient_account_deletions, [:patient_id])
  end
end
