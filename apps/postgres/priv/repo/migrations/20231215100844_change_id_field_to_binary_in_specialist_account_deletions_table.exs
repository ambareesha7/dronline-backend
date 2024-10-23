defmodule Postgres.Repo.Migrations.ChangeIdFieldToBinaryInSpecialistAccountDeletionsTable do
  use Ecto.Migration

  def change do
    alter table(:specialist_account_deletions) do
      remove :id
      add :id, :binary_id, primary_key: true
    end
  end
end
