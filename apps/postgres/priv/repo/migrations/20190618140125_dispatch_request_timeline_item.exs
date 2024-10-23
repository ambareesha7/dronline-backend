defmodule Postgres.Repo.Migrations.DispatchRequestTimelineItem do
  use Ecto.Migration

  def change do
    create table(:dispatch_request_timeline_items) do
      add :request_id, :string
      add :requester_id, :bigint
      add :record_id, :bigint
      add :patient_location_address, :map

      timestamps()
    end

    alter table(:timeline_items) do
      add :dispatch_request_id, references(:dispatch_request_timeline_items)
    end

    create index(:timeline_items, [:dispatch_request_id])
  end
end
