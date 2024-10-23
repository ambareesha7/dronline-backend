defmodule Postgres.Repo.Migrations.AddPatientIdToTimelineItems do
  use Ecto.Migration

  def change do
    alter table("timeline_items") do
      add :patient_id, :bigint
    end

    create index("timeline_items", [:patient_id])

    execute """
    UPDATE timeline_items
    SET patient_id = timelines.patient_id
    FROM timelines
    WHERE timeline_items.timeline_id = timelines.id AND timeline_items.patient_id IS NULL;
    """
  end
end
