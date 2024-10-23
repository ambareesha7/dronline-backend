defmodule Postgres.Repo.Migrations.AddSubscriptionTypeToSpecialistsTable do
  use Ecto.Migration

  def change do
    alter table(:specialists) do
      add :package_type, :string, default: "BASIC"
    end
  end
end
