defmodule Postgres.Repo.Migrations.AddSpecialistIdVisitDemands do
  use Ecto.Migration

  def change do
    alter table(:visit_demands) do
      add :specialist_id, :integer
    end
  end
end
