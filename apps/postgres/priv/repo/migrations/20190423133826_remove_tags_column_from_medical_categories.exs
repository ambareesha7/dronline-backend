defmodule Postgres.Repo.Migrations.RemoveTagsColumnFromMedicalCategories do
  use Ecto.Migration

  def change do
    alter table(:medical_categories) do
      remove :tags, {:array, :string}
    end
  end
end
