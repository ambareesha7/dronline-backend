defmodule Postgres.Repo.Migrations.RenamePatientApiTokensTable do
  use Ecto.Migration

  def change do
    rename table(:patient_api_tokens), to: table(:patient_auth_token_entries)
  end
end
