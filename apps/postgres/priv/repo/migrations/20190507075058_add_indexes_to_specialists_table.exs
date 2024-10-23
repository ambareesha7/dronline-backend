defmodule Postgres.Repo.Migrations.AddIndexesToSpecialistsTable do
  use Ecto.Migration

  def change do
    create index(:specialists, [:approval_status_updated_at])
    create index(:specialists, [:inserted_at])
  end
end
