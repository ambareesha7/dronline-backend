defmodule Postgres.Repo.Migrations.CreateSpecialistPasswordChangesTable do
  use Ecto.Migration

  def change do
    create table(:specialist_password_changes) do
      add :confirmation_token, :string, null: false
      add :expire_at, :naive_datetime_usec, null: false
      add :password_hash, :string, null: false
      add :specialist_id, references(:specialists), null: false

      timestamps()
    end

    create unique_index(:specialist_password_changes, [:confirmation_token])
  end
end
