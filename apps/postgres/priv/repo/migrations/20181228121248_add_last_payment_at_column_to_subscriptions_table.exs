defmodule Postgres.Repo.Migrations.AddLastPaymentAtColumnToSubscriptionsTable do
  use Ecto.Migration

  def change do
    alter table(:subscriptions) do
      add :last_payment_at, :naive_datetime_usec
    end

    create index(:subscriptions, [:last_payment_at])
  end
end
