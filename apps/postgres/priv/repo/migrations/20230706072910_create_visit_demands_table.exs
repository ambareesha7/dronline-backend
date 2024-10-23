defmodule Postgres.Repo.Migrations.CreateVisitDemandsTable do
  use Ecto.Migration

  def change do
    create table(:visit_demands) do
      add :patient_id, :integer
      add :medical_category_id, :integer

      timestamps()
    end
  end
end
