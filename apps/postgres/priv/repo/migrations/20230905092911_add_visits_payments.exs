defmodule Postgres.Repo.Migrations.AddVisitsPayments do
  use Ecto.Migration

  def change do
    create table(:visit_payments, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :visit_id, :integer, null: false
      add :patient_id, references(:patients, on_delete: :nothing), null: false
      add :specialist_id, references(:specialists, on_delete: :nothing), null: false
      add :team_id, references(:specialist_teams, on_delete: :nothing), null: false
      add :transaction_reference, :string
      add :price, :money_with_currency

      timestamps()
    end

    create index(:visit_payments, [:visit_id])
    create index(:visit_payments, [:patient_id])
    create index(:visit_payments, [:specialist_id])
    create index(:visit_payments, [:team_id])
  end
end
