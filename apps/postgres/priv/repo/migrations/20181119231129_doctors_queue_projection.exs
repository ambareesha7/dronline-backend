defmodule Postgres.Repo.Migrations.QueueToDoctorProjection do
  use Ecto.Migration

  def change do
    create table(:queue_to_doctor_projection) do
      add :category_id, :bigint, null: false
      add :proto, :binary

      timestamps()
    end

    create unique_index(:queue_to_doctor_projection, [:category_id])
  end
end
