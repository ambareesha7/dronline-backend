defmodule Postgres.Repo.Migrations.RemoveReferencesFromSpecialistsMedicalCategories do
  use Ecto.Migration

  def change do
    execute "ALTER TABLE specialists_medical_categories DROP CONSTRAINT specialists_medical_categories_medical_category_id_fkey"

    execute "ALTER TABLE specialists_medical_categories DROP CONSTRAINT specialists_medical_categories_specialist_id_fkey"
  end
end
