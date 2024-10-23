defmodule Postgres.Repo.Migrations.CreateMedicationOrders do
  use Ecto.Migration

  def change do
    create table(:medication_orders, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :delivery_address, :string
      add :delivery_status, :string
      add :payment_status, :string
      add :medications_bundle_id, references(:medications_bundles, on_delete: :nothing)
      add :patient_id, references(:patients, on_delete: :nothing)

      add :medications_bundle_payments_id,
          references(:medications_bundle_payments, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:medication_orders, [:medications_bundle_id])
    create index(:medication_orders, [:patient_id])
  end
end
