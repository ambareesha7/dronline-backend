defmodule Postgres.Repo.Migrations.AddDisabledToMedicalCategories do
  use Ecto.Migration

  def change do
    alter table(:medical_categories) do
      add :disabled, :boolean, default: false, null: false
      add :position, :integer
    end

    create unique_index(
             :medical_categories,
             [:position, :parent_category_id]
           )

    create unique_index(
             :medical_categories,
             [:position],
             where: "parent_category_id IS NULL"
           )

    create unique_index(
             :medical_categories,
             [:name, :parent_category_id]
           )

    create unique_index(
             :medical_categories,
             [:name],
             where: "parent_category_id IS NULL"
           )
  end
end
