defmodule Postgres.Repo.Migrations.AddMedicalLibraries do
  use Ecto.Migration

  def change do
    create table(:medical_conditions, primary_key: false) do
      add :id, :string, primary_key: true
      add :name, :string
    end

    create unique_index(:medical_conditions, [:name])

    create table(:medical_procedures, primary_key: false) do
      add :id, :string, primary_key: true
      add :name, :string
    end

    create unique_index(:medical_procedures, [:name])

    create table(:medical_summaries_conditions, primary_key: false) do
      add(
        :medical_summary_id,
        references(:medical_summaries, on_delete: :delete_all),
        primary_key: true
      )

      add(
        :condition_id,
        references(:medical_conditions, type: :string, on_delete: :delete_all),
        primary_key: true
      )
    end

    create table(:medical_summaries_procedures, primary_key: false) do
      add(
        :medical_summary_id,
        references(:medical_summaries, on_delete: :delete_all),
        primary_key: true
      )

      add(
        :procedure_id,
        references(:medical_procedures, type: :string, on_delete: :delete_all),
        primary_key: true
      )
    end
  end
end
