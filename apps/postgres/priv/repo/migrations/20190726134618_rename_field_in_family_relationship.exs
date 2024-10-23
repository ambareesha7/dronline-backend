defmodule Postgres.Repo.Migrations.RenameFieldInFamilyRelationship do
  use Ecto.Migration

  def change do
    rename table(:patients_family_relationship), :parent_patient_id, to: :adult_patient_id
  end
end
