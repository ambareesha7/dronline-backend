defmodule Postgres.Repo.Migrations.AddPatientAccountsIsSignedUp do
  use Ecto.Migration

  def change do
    alter table(:patient_accounts) do
      add :is_signed_up, :boolean, default: true
    end
  end
end
