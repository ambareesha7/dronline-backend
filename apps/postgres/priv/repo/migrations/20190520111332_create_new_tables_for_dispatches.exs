defmodule Postgres.Repo.Migrations.CreateNewTablesForDispatches do
  use Ecto.Migration

  def change do
    # PATIENTS WAITING FOR DISPATCH
    create table(:patients_waiting_for_dispatch, primary_key: false) do
      add :request_id, :string, primary_key: true
      add :patient_id, references(:patients)

      timestamps()
    end

    create unique_index(:patients_waiting_for_dispatch, [:patient_id])

    # DISPATCH REQUESTS
    create table(:dispatch_requests, primary_key: false) do
      add :request_id, :string, primary_key: true

      add :encoded_patient_location, :binary
      add :region, :string

      add :patient_id, references(:patients)
      add :record_id, references(:timelines)
      add :requester_id, references(:specialists)

      add :requested_at, :utc_datetime_usec
      timestamps()
    end

    create index(:dispatch_requests, [:requested_at])

    # ONGOING DISPATCHES
    create table(:ongoing_dispatches, primary_key: false) do
      add :request_id, :string, primary_key: true

      add :encoded_patient_location, :binary
      add :region, :string

      add :nurse_id, references(:specialists)
      add :patient_id, references(:patients)
      add :record_id, references(:timelines)
      add :requester_id, references(:specialists)

      add :accepted_at, :utc_datetime_usec
      add :requested_at, :utc_datetime_usec
      timestamps()
    end

    create unique_index(:ongoing_dispatches, [:nurse_id])
    create index(:ongoing_dispatches, [:accepted_at])

    # ENDED DISPATCHES
    create table(:ended_dispatches, primary_key: false) do
      add :request_id, :string, primary_key: true

      add :encoded_patient_location, :binary
      add :region, :string

      add :nurse_id, references(:specialists)
      add :patient_id, references(:patients)
      add :record_id, references(:timelines)
      add :requester_id, references(:specialists)

      add :accepted_at, :utc_datetime_usec
      add :ended_at, :utc_datetime_usec
      add :requested_at, :utc_datetime_usec
      timestamps()
    end
  end
end
