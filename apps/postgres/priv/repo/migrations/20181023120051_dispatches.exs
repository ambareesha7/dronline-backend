defmodule Postgres.Repo.Migrations.Dispatches do
  use Ecto.Migration

  def change do
    create table(:dispatches) do
      add :nurse_id, references(:specialists, on_delete: :delete_all), null: false
      add :operator_id, references(:specialists, on_delete: :delete_all), null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false

      add :city, :string
      add :country, :string
      add :home, :string
      add :postal_code, :string
      add :street, :string

      add :finished, :boolean, default: false

      timestamps()
    end

    create index(:dispatches, [:nurse_id])
    create index(:dispatches, [:operator_id])
    create index(:dispatches, [:user_id])

    create index(:dispatches, [:finished])

    create unique_index(:dispatches, [:nurse_id],
             where: "finished = false",
             name: "current_dispatch_index"
           )
  end
end
