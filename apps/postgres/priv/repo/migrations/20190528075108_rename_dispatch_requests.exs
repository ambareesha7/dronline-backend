defmodule Postgres.Repo.Migrations.RenameDispatchRequests do
  use Ecto.Migration

  def change do
    rename table(:dispatch_requests), to: table(:pending_dispatches)

    execute """
    ALTER INDEX dispatch_requests_pkey RENAME TO pending_dispatches_pkey;
    """

    execute """
    ALTER INDEX dispatch_requests_requested_at_index RENAME TO pending_dispatches_requested_at_index;
    """

    execute """
    ALTER TABLE pending_dispatches
      RENAME CONSTRAINT dispatch_requests_patient_id_fkey TO pending_dispatches_patient_id_fkey;
    """

    execute """
    ALTER TABLE pending_dispatches
      RENAME CONSTRAINT dispatch_requests_record_id_fkey TO pending_dispatches_record_id_fkey;
    """

    execute """
    ALTER TABLE pending_dispatches
      RENAME CONSTRAINT dispatch_requests_requester_id_fkey TO pending_dispatches_requester_id_fkey;
    """
  end
end
