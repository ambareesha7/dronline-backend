defmodule Postgres.Repo.Migrations.AddTypeFieldToPendingVisitsTable do
  use Ecto.Migration

  def change do
    alter table(:pending_visits) do
      add :visit_type, :string
    end
  end
end
