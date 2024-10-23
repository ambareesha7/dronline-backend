defmodule Postgres.Repo.Migrations.UpdatePendingWithdrawals do
  use Ecto.Migration

  def change do
    alter table(:pending_withdrawals) do
      remove :medical_category_id
      add :visit_id, :binary_id
    end
  end
end
