defmodule Postgres.Repo.Migrations.AddClosedAtToTimelinesTable do
  use Ecto.Migration

  def change do
    alter table(:timelines) do
      add :closed_at, :naive_datetime_usec
    end
  end
end
