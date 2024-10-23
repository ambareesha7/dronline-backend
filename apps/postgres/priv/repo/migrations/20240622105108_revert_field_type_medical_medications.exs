defmodule Postgres.Repo.Migrations.RevertFieldTypeMedicalMedications do
  use Ecto.Migration

  def change do
    alter table(:medical_medications) do
      modify :price_aed, :integer, from: :float, default: 0
    end
  end
end
