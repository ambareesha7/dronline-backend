defmodule Postgres.Repo.Migrations.AddDocumentsUploadedToVisit do
  use Ecto.Migration

  def change do
    create table(:visits_uploaded_documents, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :patient_id, :integer, null: false
      add :record_id, :integer, null: false
      add :document_url, :string

      timestamps()
    end

    create index(:visits_uploaded_documents, [:record_id, :patient_id])
    create index(:visits_uploaded_documents, [:record_id])
  end
end
