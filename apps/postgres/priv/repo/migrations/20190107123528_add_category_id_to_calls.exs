defmodule Postgres.Repo.Migrations.AddCategoryIdToCalls do
  use Ecto.Migration

  def change do
    alter table(:calls) do
      add :medical_category_id, references("medical_categories")
    end
  end
end
