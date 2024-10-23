defmodule Postgres.Repo.Migrations.AddWebviewUrlColumnToSubscriptionsTable do
  use Ecto.Migration

  def change do
    alter table(:subscriptions) do
      add :webview_url, :string
    end
  end
end
