defmodule Postgres.Repo.Migrations.RemoveTimelineItemsLeftAfterRemovingOldDispatches do
  use Ecto.Migration

  def change do
    execute """
    DELETE FROM timeline_items
    WHERE call_id IS NULL AND vitals_id IS NULL AND doctor_invitation_id IS NULL;
    """
  end
end
