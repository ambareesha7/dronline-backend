defmodule Postgres.Repo.Migrations.SetPatientAccountsFirebaseIdAsOptional do
  use Ecto.Migration

  def change do
    alter table(:patient_accounts) do
      modify :firebase_id, :string, null: true
    end
  end
end
