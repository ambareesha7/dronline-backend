defmodule Postgres.Repo.Migrations.AddSpecialistIdToRos do
  use Ecto.Migration

  def change do
    alter table(:reviews_of_system) do
      add :provided_by_specialist_id, :bigint
    end
  end
end
