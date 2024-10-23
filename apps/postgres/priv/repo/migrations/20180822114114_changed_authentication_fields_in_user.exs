defmodule Postgres.Repo.Migrations.ChangedAuthenticationFieldsInUser do
  use Ecto.Migration

  def change do
    alter table(:users) do
      remove :verified
      remove :email
      remove :password_hash
      remove :verification_token
      remove :password_recovery_token

      add :firebase_id, :string, null: false
    end

    create unique_index(:users, [:firebase_id])
  end
end
