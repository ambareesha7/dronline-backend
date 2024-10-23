defmodule Postgres.Repo.Migrations.CreatePayoutsCredentials do
  use Ecto.Migration

  def change do
    create table(:specialist_payouts_credentials, primary_key: false) do
      add :specialist_id, :integer, primary_key: true
      add :iban, :string, null: false
      add :name, :string
      add :address, :string
      add :bank_name, :string
      add :bank_address, :string
      add :bank_swift_code, :string
      add :bank_routing_number, :string

      timestamps()
    end

    create unique_index(:specialist_payouts_credentials, [:iban])
  end
end
