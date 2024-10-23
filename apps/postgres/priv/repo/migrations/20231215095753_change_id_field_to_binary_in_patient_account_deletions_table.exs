defmodule Postgres.Repo.Migrations.ChangeIdFieldToBinaryInPatientAccountDeletionsTable do
  use Ecto.Migration

  def change do
    alter table(:patient_account_deletions) do
      remove :id
      add :id, :binary_id, primary_key: true
    end
  end
end
