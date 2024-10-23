defmodule Postgres.Repo.Migrations.AddCurrenciesToPrices do
  use Ecto.Migration

  def change do
    alter table(:specialists_medical_categories) do
      add :currency, :string
    end
  end
end
