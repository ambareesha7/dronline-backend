defmodule Postgres.Repo.Migrations.CreateCanceledVisitsTable do
  use Ecto.Migration

  def up do
    create table(:canceled_visits, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :start_time, :bigint

      add :patient_id, :bigint
      add :record_id, :bigint
      add :specialist_id, :bigint
      add :chosen_medical_category_id, :bigint
      add :canceled_at, :utc_datetime_usec, default: fragment("now()"), null: false
      add :canceled_by, :string, null: false

      timestamps()
    end

    create index(:canceled_visits, [:patient_id])
    create index(:canceled_visits, [:specialist_id])

    execute("DROP VIEW IF EXISTS visits_log")

    execute """
    CREATE VIEW visits_log AS
      SELECT
        id,
        start_time,
        chosen_medical_category_id,
        patient_id,
        record_id,
        specialist_id,
        'PENDING' AS state,
        inserted_at,
        updated_at
      FROM
        pending_visits
      UNION ALL
      SELECT
        id,
        start_time,
        chosen_medical_category_id,
        patient_id,
        record_id,
        specialist_id,
        'CANCELED' AS state,
        inserted_at,
        updated_at
      FROM
        canceled_visits
      UNION ALL
      SELECT
        id,
        start_time,
        chosen_medical_category_id,
        patient_id,
        record_id,
        specialist_id,
        'ENDED' AS state,
        inserted_at,
        updated_at
      FROM
        ended_visits;
    """
  end

  def down do
    execute("DROP VIEW IF EXISTS visits_log")
    drop table(:canceled_visits)
  end
end
