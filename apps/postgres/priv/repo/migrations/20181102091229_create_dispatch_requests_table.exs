defmodule Postgres.Repo.Migrations.CreateDispatchRequestsTable do
  use Ecto.Migration

  def change do
    create table(:dispatch_requests) do
      add :operator_id, references(:specialists, on_delete: :delete_all, null: false)
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :timeline_id, references(:timelines, on_delete: :delete_all, null: false)

      add :city, :string
      add :country, :string
      add :home, :string
      add :postal_code, :string
      add :street, :string

      timestamps()
    end

    create index(:dispatch_requests, [:operator_id])
    create index(:dispatch_requests, [:user_id])
    create index(:dispatch_requests, [:timeline_id])
  end
end
