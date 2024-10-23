defmodule Postgres.Repo.Migrations.DeleteDaySchedulesV1 do
  use Ecto.Migration

  def change do
    drop table(:specialist_day_schedules)
  end
end
