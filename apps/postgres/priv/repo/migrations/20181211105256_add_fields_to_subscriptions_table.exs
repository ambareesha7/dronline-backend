defmodule Postgres.Repo.Migrations.AddFieldsToSubscriptionsTable do
  use Ecto.Migration

  def change do
    alter table(:subscriptions) do
      add :agreement_id, :string
      add :accepted_at, :naive_datetime_usec
      add :declined_at, :naive_datetime_usec
      add :next_payment_count, :integer, default: 1
      add :status, :string
    end
  end
end
