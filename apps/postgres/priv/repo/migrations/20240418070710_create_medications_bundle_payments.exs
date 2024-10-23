defmodule Postgres.Repo.Migrations.CreateMedicationsBundlePayments do
  use Ecto.Migration

  def change do
    create table(:medications_bundle_payments, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :medications_bundle_id,
          references(:medications_bundles, type: :integer, on_delete: :nothing),
          null: false

      add :transaction_reference, :string
      add :payment_method, :string
      add :price, :money_with_currency

      timestamps()
    end

    create unique_index(:medications_bundle_payments, [:medications_bundle_id])
  end
end
