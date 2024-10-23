defmodule Postgres.Repo.Migrations.CreateMedicalCategoryTable do
  use Ecto.Migration

  def change do
    create table(:medical_categories) do
      add :name, :string
      add :image_url, :string
      add :tags, {:array, :string}
      add :what_we_treat_url, :string

      add :parent_category_id, references(:medical_categories), null: true

      timestamps()
    end

    create index(:medical_categories, [:parent_category_id])
  end
end
