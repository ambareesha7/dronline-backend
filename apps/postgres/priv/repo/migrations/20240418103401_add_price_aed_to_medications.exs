defmodule Postgres.Repo.Migrations.AddPriceAedToMedications do
  use Ecto.Migration

  def change do
    alter table(:medical_medications) do
      add :price_aed, :integer
    end
  end
end
