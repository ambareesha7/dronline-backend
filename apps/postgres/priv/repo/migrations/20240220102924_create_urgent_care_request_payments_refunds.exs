defmodule Postgres.Repo.Migrations.CreateUrgentCareRequestPaymentsRefunds do
  use Ecto.Migration

  def up do
    create table(:urgent_care_request_payments_refunds, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :payment_id,
          references(:urgent_care_request_payments, type: :binary_id, on_delete: :nothing),
          null: false

      add :reason, :string

      timestamps()
    end

    create index(:urgent_care_request_payments_refunds, [:payment_id])

    alter table(:urgent_care_requests) do
      add :canceled_at, :utc_datetime_usec
    end
  end

  def down do
    drop_if_exists table(:urgent_care_request_payments_refunds)

    alter table(:urgent_care_requests) do
      remove :canceled_at
    end
  end
end
