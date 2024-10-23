defmodule Postgres.Repo.Migrations.AddSpecialistAccountDeletionsTable do
  use Ecto.Migration

  def change do
    create table(:specialist_account_deletions) do
      add :specialist_id, :integer
      add :status, :string

      timestamps()
    end

    create unique_index(:specialist_account_deletions, [:specialist_id])
  end
end
