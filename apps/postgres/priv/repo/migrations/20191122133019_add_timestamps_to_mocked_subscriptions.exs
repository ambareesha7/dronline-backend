defmodule Postgres.Repo.Migrations.AddTimestampsToMockedSubscriptions do
  use Ecto.Migration

  def change do
    alter table(:mocked_subscriptions) do
      add :inserted_at, :naive_datetime_usec
      add :updated_at, :naive_datetime_usec
    end

    execute("UPDATE mocked_subscriptions SET inserted_at = NOW(), updated_at = NOW();")

    alter table(:mocked_subscriptions) do
      modify :inserted_at, :naive_datetime_usec, null: false
      modify :updated_at, :naive_datetime_usec, null: false
    end
  end
end
