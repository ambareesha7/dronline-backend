defmodule Postgres.Repo.Migrations.CreatePendingWithdrawalsTable do
  use Ecto.Migration

  def change do
    create table(:pending_withdrawals, primary_key: false) do
      add :record_id, :integer, primary_key: true
      add :patient_id, :integer
      add :specialist_id, :integer
      add :medical_category_id, :integer
      add :amount, :integer

      timestamps()
    end
  end
end
