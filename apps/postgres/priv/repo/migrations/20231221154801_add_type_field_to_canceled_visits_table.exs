defmodule Postgres.Repo.Migrations.AddTypeFieldToCanceledVisitsTable do
  use Ecto.Migration

  def change do
    alter table(:canceled_visits) do
      add :visit_type, :string
    end
  end
end
