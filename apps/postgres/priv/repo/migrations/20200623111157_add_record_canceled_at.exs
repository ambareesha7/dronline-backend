defmodule Postgres.Repo.Migrations.AddRecordCanceledAt do
  use Ecto.Migration

  def change do
    alter table(:timelines) do
      add :canceled_at, :naive_datetime_usec
    end
  end
end
