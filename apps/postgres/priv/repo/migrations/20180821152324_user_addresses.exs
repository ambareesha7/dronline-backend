defmodule Postgres.Repo.Migrations.UserAddresses do
  use Ecto.Migration

  def change do
    create table(:user_addresses) do
      add :street, :string
      add :home_number, :string
      add :zip_code, :string
      add :city, :string
      add :country, :string

      add :user_id, references(:users, on_delete: :delete_all), null: false
    end

    create index(:user_addresses, [:user_id])
  end
end
