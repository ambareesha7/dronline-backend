defmodule Postgres.Repo.Migrations.AddPatientLocationAddressToDispatches do
  use Ecto.Migration

  def change do
    alter table(:pending_dispatches) do
      add :patient_location_address, :map
    end

    alter table(:ongoing_dispatches) do
      add :patient_location_address, :map
    end

    alter table(:ended_dispatches) do
      add :patient_location_address, :map
    end

    execute "DROP VIEW current_dispatches;"

    execute """
    CREATE VIEW current_dispatches AS
      SELECT
        request_id,
        patient_location_address,
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
        patient_location_address,
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
end
