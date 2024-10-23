defmodule Postgres.Repo.Migrations.CreateCurrentDispatchesView do
  use Ecto.Migration

  def up do
    execute """
    CREATE VIEW current_dispatches AS
      SELECT
        request_id,
        encoded_patient_location,
        region,
        NULL AS nurse_id,
        patient_id,
        record_id,
        requester_id,
        NULL AS taken_at,
        requested_at,
        'PENDING' AS status,
        inserted_at,
        updated_at
      FROM
        pending_dispatches
      UNION ALL
      SELECT
        request_id,
        encoded_patient_location,
        region,
        nurse_id,
        patient_id,
        record_id,
        requester_id,
        taken_at,
        requested_at,
        'ONGOING' AS status,
        inserted_at,
        updated_at
      FROM
        ongoing_dispatches;
    """
  end

  def down do
    execute "DROP VIEW current_dispatches;"
  end
end
