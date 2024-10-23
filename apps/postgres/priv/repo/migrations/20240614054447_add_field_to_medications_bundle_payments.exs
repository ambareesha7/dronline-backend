defmodule Postgres.Repo.Migrations.AddFieldToMedicationsBundlePayments do
  use Ecto.Migration

  def change do
    alter table(:medications_bundle_payments) do
      add :medication_order_id,
          references(:medication_orders, type: :binary_id, on_delete: :nothing)
    end

    create index(:medications_bundle_payments, [:medication_order_id])
  end
end
