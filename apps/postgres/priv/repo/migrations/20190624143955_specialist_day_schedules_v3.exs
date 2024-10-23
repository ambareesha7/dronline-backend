defmodule Postgres.Repo.Migrations.SpecialistDaySchedulesV3 do
  use Ecto.Migration

  def change do
    create table("specialist_day_schedules_v3") do
      add :specialist_id, :bigint
      add :date, :date

      add :free_timeslots, :jsonb, default: "[]"
      add :taken_timeslots, :jsonb, default: "[]"

      add :free_timeslots_count, :integer
      add :taken_timeslots_count, :integer

      timestamps()
    end

    create unique_index(:specialist_day_schedules_v3, [:specialist_id, :date])

    create index(:specialist_day_schedules_v3, [:free_timeslots_count])
    create index(:specialist_day_schedules_v3, [:taken_timeslots_count])
  end
end
