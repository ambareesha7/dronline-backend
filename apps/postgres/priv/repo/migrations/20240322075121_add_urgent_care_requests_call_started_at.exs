defmodule Postgres.Repo.Migrations.AddUrgentCareRequestsCallStartedAt do
  use Ecto.Migration

  def change do
    alter table(:urgent_care_requests) do
      add :call_started_at, :utc_datetime_usec
    end
  end
end
