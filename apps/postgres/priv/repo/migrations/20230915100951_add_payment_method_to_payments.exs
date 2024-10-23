defmodule Postgres.Repo.Migrations.AddPaymentMethodToPayments do
  use Ecto.Migration

  def change do
    alter table(:visit_payments) do
      add :payment_method, :string

      modify :team_id,
             references(:specialist_teams, on_delete: :nothing),
             null: true,
             from: references(:specialist_teams, on_delete: :nothing)
    end

    create index(:visit_payments, [:payment_method])
  end
end
