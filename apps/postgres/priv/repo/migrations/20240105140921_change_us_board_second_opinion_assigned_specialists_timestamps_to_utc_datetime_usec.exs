defmodule Postgres.Repo.Migrations.ChangeUsBoardSecondOpinionAssignedSpecialistsTimestampsToUtcDatetimeUsec do
  # credo:disable-for-this-file
  use Ecto.Migration

  def up do
    alter table(:us_board_second_opinion_assigned_specialists) do
      modify :assigned_at, :utc_datetime_usec
      modify :accepted_at, :utc_datetime_usec
      modify :rejected_at, :utc_datetime_usec
    end
  end

  def down do
    alter table(:us_board_second_opinion_assigned_specialists) do
      modify :assigned_at, :utc_datetime
      modify :accepted_at, :utc_datetime
      modify :rejected_at, :utc_datetime
    end
  end
end
