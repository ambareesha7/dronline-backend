defmodule Postgres.Repo.Migrations.AddPasswordRecoveryToken do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :password_recovery_token, :string
    end

    create unique_index(:users, [:password_recovery_token])
  end
end
