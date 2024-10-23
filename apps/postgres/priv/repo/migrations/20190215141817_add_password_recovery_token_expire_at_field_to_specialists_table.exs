defmodule Postgres.Repo.Migrations.AddPasswordRecoveryTokenExpireAtFieldToSpecialistsTable do
  use Ecto.Migration

  def change do
    alter table(:specialists) do
      add :password_recovery_token_expire_at, :naive_datetime_usec
    end
  end
end
