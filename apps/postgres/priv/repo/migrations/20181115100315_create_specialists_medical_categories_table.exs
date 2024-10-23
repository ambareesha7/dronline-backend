defmodule Postgres.Repo.Migrations.CreateSpecialistsMedicalCategoriesTable do
  use Ecto.Migration

  def change do
    create table(:specialists_medical_categories) do
      add :specialist_id, references(:specialists)
      add :medical_category_id, references(:medical_categories)
    end

    create index(:specialists_medical_categories, [:specialist_id])
    create index(:specialists_medical_categories, [:medical_category_id])
  end
end
