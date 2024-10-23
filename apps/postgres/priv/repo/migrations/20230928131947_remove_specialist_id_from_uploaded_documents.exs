defmodule Postgres.Repo.Migrations.RemoveSpecialistIdFromUploadedDocuments do
  use Ecto.Migration

  def change do
    alter table(:visits_uploaded_documents) do
      remove_if_exists(:specialist_id, :integer)
    end
  end
end
