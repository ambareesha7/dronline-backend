defmodule Postgres.Repo.Migrations.AddPatientIdToHpi do
  use Ecto.Migration

  def change do
    alter table("hpis") do
      add :patient_id, :bigint
    end

    create index("hpis", [:patient_id])

    execute """
    UPDATE hpis
    SET patient_id = timelines.patient_id
    FROM timelines
    WHERE hpis.timeline_id = timelines.id AND hpis.patient_id IS NULL;
    """
  end
end
