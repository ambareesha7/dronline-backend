defmodule Postgres.Repo.Migrations.CreateUrgentCareRequestPayments do
  use Ecto.Migration

  def up do
    create table(:urgent_care_request_payments, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :urgent_care_request_id,
          references(:urgent_care_requests, type: :binary_id, on_delete: :nothing),
          null: false

      add :transaction_reference, :string
      add :payment_method, :string
      add :price, :money_with_currency

      timestamps()
    end

    create index(:urgent_care_request_payments, [:urgent_care_request_id])
  end

  def down do
    drop table(:urgent_care_request_payments)
    drop index(:urgent_care_request_payments, [:urgent_care_request_id])
  end
end
