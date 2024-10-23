defmodule Postgres.Repo.Migrations.SplitPatients do
  use Ecto.Migration

  def change do
    create table(:patient_accounts) do
      add :firebase_id, :string, null: false
      add :phone_number, :string, null: false

      add :main_patient_id, :bigint, null: false

      timestamps()
    end

    create unique_index(:patient_accounts, [:firebase_id])
    create unique_index(:patient_accounts, [:phone_number])
    create unique_index(:patient_accounts, [:main_patient_id])

    create table(:patient_api_tokens, primary_key: false) do
      add :patient_id, :bigint, primary_key: true
      add :auth_token, :string, null: false

      timestamps()
    end

    create unique_index(:patient_api_tokens, [:auth_token])

    execute """
    INSERT INTO
      patient_accounts(main_patient_id, firebase_id, phone_number, inserted_at, updated_at)
    SELECT
      id,
      firebase_id,
      phone_number,
      inserted_at,
      updated_at
    FROM
      patients;
    """

    execute """
    INSERT INTO
      patient_api_tokens(patient_id, auth_token, inserted_at, updated_at)
    SELECT
      id,
      auth_token,
      inserted_at,
      updated_at
    FROM
      patients;
    """

    drop index(:patients, [:firebase_id])
    drop index(:patients, [:phone_number])
    drop index(:patients, [:auth_token])

    alter table(:patients) do
      # TODO remove those fields later
      modify :firebase_id, :string, null: true
      modify :auth_token, :string, null: true
    end
  end
end
