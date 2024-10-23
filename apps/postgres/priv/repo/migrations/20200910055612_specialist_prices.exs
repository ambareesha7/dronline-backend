defmodule Postgres.Repo.Migrations.SpecialistPrices do
  use Ecto.Migration

  def change do
    alter table(:specialists_medical_categories) do
      add :price_minutes_15, :integer, default: 0
      add :price_minutes_30, :integer, default: 0
      add :price_minutes_45, :integer, default: 0
      add :price_minutes_60, :integer, default: 0
      add :price_second_opinion, :integer, default: 0
    end
  end
end
