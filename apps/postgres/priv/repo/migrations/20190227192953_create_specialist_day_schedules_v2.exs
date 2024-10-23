defmodule Postgres.Repo.Migrations.CreateSpecialistDaySchedulesV2 do
  use Ecto.Migration

  def change do
    create table(:specialist_day_schedules_v2) do
      add :specialist_id, :integer, null: false
      add :date, :date, null: false

      add :free_slots_map, :binary, null: false
      add :taken_slots_map, :binary, null: false

      add :free_slots_count, :integer, null: false

      timestamps()
    end

    create unique_index(:specialist_day_schedules_v2, [:specialist_id, :date])
    create index(:specialist_day_schedules_v2, [:free_slots_count])
  end
end
