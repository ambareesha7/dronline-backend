defmodule Postgres.Repo.Migrations.MockedSubscriptions do
  use Ecto.Migration

  def change do
    create table(:mocked_subscriptions, primary_key: false) do
      add :specialist_id, :bigint, primary_key: true

      add :type, :string
    end

    create unique_index(:mocked_subscriptions, [:specialist_id])
  end
end
