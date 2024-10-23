defmodule Postgres.Repo.Migrations.RecordsAutocloseSaga do
  use Ecto.Migration

  def change do
    create table(:records_autoclose_saga, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :encoded_state, :binary

      add :patient_id, :bigint
      add :record_id, :bigint

      timestamps()
    end

    create unique_index(:records_autoclose_saga, [:patient_id, :record_id])
  end
end
