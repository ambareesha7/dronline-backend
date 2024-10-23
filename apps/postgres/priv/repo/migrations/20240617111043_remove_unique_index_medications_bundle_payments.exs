defmodule Postgres.Repo.Migrations.RemoveUniqueIndexMedicationsBundlePayments do
  use Ecto.Migration

  def change do
    drop_if_exists unique_index(:medications_bundle_payments, [:medications_bundle_id])
  end
end
