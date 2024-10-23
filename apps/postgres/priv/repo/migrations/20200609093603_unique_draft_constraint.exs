defmodule Postgres.Repo.Migrations.UniqueDraftConstraint do
  use Ecto.Migration

  def up do
    execute """
    CREATE UNIQUE INDEX unique_draft_constraint 
      ON medical_summaries (specialist_id, timeline_id)
      WHERE is_draft=true;
    """
  end

  def down do
    execute "DROP INDEX unique_draft_constraint"
  end
end
