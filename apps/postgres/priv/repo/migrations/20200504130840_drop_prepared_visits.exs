defmodule Postgres.Repo.Migrations.DropPreparedVisits do
  use Ecto.Migration

  def up do
    execute("DROP VIEW IF EXISTS visits_log")
    drop table(:prepared_visits)

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
        'ENDED' AS state,
        inserted_at,
        updated_at
      FROM
        ended_visits;
    """
  end

  def down, do: nil
end
