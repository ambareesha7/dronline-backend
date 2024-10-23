defmodule Postgres.Repo.Migrations.RenameDispatchesAcceptedAtToTakenAt do
  use Ecto.Migration

  def change do
    rename table(:ongoing_dispatches), :accepted_at, to: :taken_at
    rename table(:ended_dispatches), :accepted_at, to: :taken_at

    execute """
    ALTER INDEX ongoing_dispatches_accepted_at_index RENAME TO ongoing_dispatches_taken_at_index;
    """
  end
end
