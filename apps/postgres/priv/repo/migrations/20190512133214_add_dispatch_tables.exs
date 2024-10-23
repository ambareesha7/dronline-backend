defmodule Postgres.Repo.Migrations.AddDispatchTables do
  use Ecto.Migration

  def change do
    create table(:unassigned_dispatches, primary_key: false) do
      add :request_id, :string, primary_key: true

      add :address, :binary, null: false
      add :region, :string, null: false
      add :timestamp, :integer, null: false

      add :patient_id, :bigint, null: false
      add :record_id, :bigint, null: false
      add :specialist_id, :bigint, null: false

      timestamps()
    end

    create index(:unassigned_dispatches, [:timestamp])

    create table(:dispatches_in_progress, primary_key: false) do
      add :request_id, :string, primary_key: true

      add :address, :binary, null: false
      add :region, :string, null: false
      add :timestamp, :integer, null: false

      add :nurse_id, :bigint, null: false
      add :patient_id, :bigint, null: false
      add :record_id, :bigint, null: false
      add :specialist_id, :bigint, null: false

      timestamps()
    end

    create index(:dispatches_in_progress, [:nurse_id])
  end
end
