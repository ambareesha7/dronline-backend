defmodule Postgres.Repo.Migrations.AddMedicalTests do
  use Ecto.Migration

  def change do
    create table(:medical_tests_categories) do
      add :name, :string
      add :disabled, :boolean, default: false, null: false
    end

    create unique_index(:medical_tests_categories, [:name])

    create table(:medical_tests) do
      add :name, :string
      add :disabled, :boolean, default: false, null: false
      add :category_id, references(:medical_tests_categories), null: false
    end

    create unique_index(:medical_tests, [:category_id, :name])

    create table(:ordered_tests_bundles) do
      add :timeline_id, :bigint, null: false
      add :specialist_id, :bigint, null: false
      add :patient_id, :bigint, null: false
      timestamps()
    end

    create table(:ordered_tests) do
      add :description, :string

      add :medical_test_id,
          references(:medical_tests),
          null: false

      add :bundle_id,
          references(:ordered_tests_bundles),
          null: false

      timestamps()
    end

    create unique_index(:ordered_tests, [:bundle_id, :medical_test_id])
    create index(:ordered_tests, [:bundle_id])

    alter table(:timeline_items) do
      add :ordered_tests_bundle_id, :bigint
    end
  end
end
