defmodule Postgres.Repo.Migrations.AddUniqueIndexForManualTimelines do
  use Ecto.Migration

  def change do
    execute """
    UPDATE timelines
    SET active = false, closed_at = NOW(), updated_at = NOW()
    WHERE active = true and type = 'MANUAL';
    """

    create unique_index(:timelines, [:patient_id, :creator_id],
             where: "active = true and type = 'MANUAL'",
             name: "current_manual_timeline_index"
           )
  end
end
