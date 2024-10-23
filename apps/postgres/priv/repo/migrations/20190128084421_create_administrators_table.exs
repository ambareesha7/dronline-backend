defmodule Postgres.Repo.Migrations.CreateAdministratorsTable do
  use Ecto.Migration

  def change do
    create table(:administrators) do
      add :email, :string, null: false

      add :auth_token, :string, null: false
      add :password_hash, :string, null: false

      timestamps()
    end

    create index(:administrators, [:auth_token])
    create index(:administrators, [:email])
  end
end
