defmodule Postgres.Repo.Migrations.UsersTable do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :auth_token, :string, null: false
      add :verified, :bool, null: false, default: false

      add :email, :string, null: false
      add :password_hash, :string, null: false
      add :email_token, :string
    end

    create unique_index(:users, [:auth_token])
    create unique_index(:users, [:email])
    create unique_index(:users, [:email_token], where: "email_token IS NOT NULL")

    create index(:users, [:verified])

    check = "email_token IS NULL OR verified = false"
    create constraint(:users, "email_already_taken", check: check)
  end
end
