defmodule Postgres.Repo.Migrations.AddIconUrlAndVisitTypeToMedicalCategory do
  use Ecto.Migration

  def change do
    alter table(:medical_categories) do
      add :icon_url, :string
      add :visit_type, :string, default: "BOTH"
    end
  end
end
