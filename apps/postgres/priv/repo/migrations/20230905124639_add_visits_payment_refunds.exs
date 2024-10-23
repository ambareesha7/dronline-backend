defmodule Postgres.Repo.Migrations.AddVisitsPaymentRefunds do
  use Ecto.Migration

  def change do
    create table(:visit_payment_refunds, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :payment_id, references(:visit_payments, type: :binary_id, on_delete: :nothing),
        null: false

      add :requested_by, :string
      add :requester_id, :integer

      timestamps()
    end

    create index(:visit_payment_refunds, [:payment_id])
    create index(:visit_payment_refunds, [:requester_id])
  end
end
