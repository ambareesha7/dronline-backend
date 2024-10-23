defmodule Postgres.Repo.Migrations.RenameEmailToken do
  use Ecto.Migration

  def up do
    rename table(:users), :email_token, to: :verification_token
    execute("ALTER INDEX users_email_token_index RENAME TO users_verification_token_index")
  end

  def down do
    rename table(:users), :verification_token, to: :email
    execute("ALTER INDEX users_verification_token_index RENAME TO users_email_token_index")
  end
end
