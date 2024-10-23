defmodule Postgres.Repo.Migrations.CreateMissingIndexesForSortingStaff do
  use Ecto.Migration

  def change do
    create index(:specialist_basic_infos, [:first_name])
    create index(:specialist_basic_infos, [:last_name])

    create index(:specialists, [:onboarding_completed_at])
  end
end
