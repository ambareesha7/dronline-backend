defmodule Postgres.Repo.Migrations.AddUniqueIndexToSubscriptions do
  use Ecto.Migration

  def change do
    create unique_index(:subscriptions, [:specialist_id],
             where: "status = 'PENDING'",
             name: "unique_pending_subscription_index"
           )
  end
end
