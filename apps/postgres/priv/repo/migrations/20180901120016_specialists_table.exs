defmodule Postgres.Repo.Migrations.SpecialistsTable do
  use Ecto.Migration

  def change do
    create table(:specialists) do
      add :type, :string, null: false

      add :medical_id, :string, null: false
      add :email, :string, null: false
      add :password_hash, :string, null: false
      add :auth_token, :string, null: false

      add :verified, :boolean, default: false
      add :verification_token, :string

      add :password_recovery_token, :string
    end

    create index(:specialists, [:type])

    create unique_index(:specialists, [:medical_id])
    create unique_index(:specialists, [:email])
    create unique_index(:specialists, [:auth_token])

    create unique_index(:specialists, [:verification_token],
             where: "verification_token IS NOT NULL"
           )

    create unique_index(:specialists, [:password_recovery_token],
             where: "password_recovery_token IS NOT NULL"
           )
  end
end
