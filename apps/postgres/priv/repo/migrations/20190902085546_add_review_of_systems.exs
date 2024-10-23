defmodule Postgres.Repo.Migrations.AddReviewOfSystems do
  use Ecto.Migration

  def change do
    create table(:reviews_of_system, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :encoded_form, :binary

      add :patient_id, :integer

      timestamps()
    end

    create index(:reviews_of_system, [:patient_id])
    create index(:reviews_of_system, [:inserted_at])
  end
end
