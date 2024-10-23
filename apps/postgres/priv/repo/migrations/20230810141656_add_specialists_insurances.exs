defmodule Postgres.Repo.Migrations.AddSpecialistsInsuranceProviders do
  use Ecto.Migration

  def change do
    create table(:specialists_insurance_providers) do
      add :specialist_id, references(:specialists, on_delete: :delete_all), null: false
      add :provider_id, references(:insurance_providers, on_delete: :delete_all), null: false
    end

    create index(:specialists_insurance_providers, [:specialist_id])
    create index(:specialists_insurance_providers, [:provider_id])
  end
end
