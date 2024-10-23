defmodule Postgres.Repo.Migrations.CreateUrgentCareRequests do
  use Ecto.Migration

  def up do
    create table(:urgent_care_requests, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :patient_id, :integer
      add :specialist_id, :integer
      add :team_id, :integer

      timestamps()
    end
  end

  def down do
    drop table(:urgent_care_requests)
  end
end
