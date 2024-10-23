defmodule Postgres.Repo.Migrations.RemoveNotNullConstraintFromMedicalId do
  use Ecto.Migration

  def change do
    alter table(:specialists) do
      modify :medical_id, :string, null: true
    end
  end
end
