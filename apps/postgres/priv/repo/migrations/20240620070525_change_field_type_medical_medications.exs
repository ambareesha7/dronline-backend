defmodule Postgres.Repo.Migrations.ChangeFieldTypeMedicalMedications do
  use Ecto.Migration

  def change do
    alter table(:medical_medications) do
      modify :price_aed, :float, from: :integer, default: 0.0
    end
  end
end
