defmodule Postgres.Repo.Migrations.AddChosenMedicalCategoryIdToVisits do
  use Ecto.Migration

  def change do
    alter table(:pending_visits) do
      add :chosen_medical_category_id, :bigint
    end

    alter table(:prepared_visits) do
      add :chosen_medical_category_id, :bigint
    end
  end
end
