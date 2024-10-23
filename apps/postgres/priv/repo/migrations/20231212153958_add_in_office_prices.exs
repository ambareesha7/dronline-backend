defmodule Postgres.Repo.Migrations.AddInOfficePrices do
  use Ecto.Migration

  def change do
    alter table(:specialists_medical_categories) do
      add :price_in_office, :integer, default: 0
      add :currency_in_office, :string
    end
  end
end
