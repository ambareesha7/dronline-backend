defmodule Postgres.Repo.Migrations.AddVisitTypeToVisitLogViewAndEndedVisitsTable do
  use Ecto.Migration

  def up do
    alter table(:ended_visits) do
      add :visit_type, :string, default: "ONLINE", null: false
    end

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
        visit_type,
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
        visit_type,
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
        visit_type,
        inserted_at,
        updated_at
      FROM
        ended_visits;
    """
  end

  def down do
    execute("DROP VIEW IF EXISTS visits_log")

    alter table(:ended_visits) do
      remove :visit_type
    end

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
end
