defmodule Postgres.Repo.Migrations.AddVisitedPricesScreenFlag do
  use Ecto.Migration

  def change do
    alter table(:specialists) do
      add :has_seen_pricing_tables, :boolean, default: false
    end
  end
end
