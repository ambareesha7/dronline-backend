defmodule Postgres.Repo.Migrations.CreateSubscriptionsTable do
  use Ecto.Migration

  def change do
    create table(:subscriptions) do
      add :specialist_id, references(:specialists), null: false
      add :order_id, :string, null: false
      add :next_payment_date, :date
      add :day, :integer
      add :checked_at, :naive_datetime_usec, null: false, default: fragment("now()")
      add :cancelled_at, :naive_datetime_usec
      add :ended_at, :naive_datetime_usec
      add :active, :boolean, default: false
      add :ref, :string
      add :type, :string, null: false, default: "NEW"
    end

    create index(:subscriptions, [:specialist_id])

    create unique_index(:subscriptions, [:specialist_id],
             where: "active = true",
             name: "current_subscription_index"
           )

    create unique_index(:subscriptions, [:order_id])

    create index(:subscriptions, [:active])
    create index(:subscriptions, [:checked_at])
    create index(:subscriptions, [:next_payment_date])
  end
end
