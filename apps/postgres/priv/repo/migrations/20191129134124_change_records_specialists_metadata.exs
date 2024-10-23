defmodule Postgres.Repo.Migrations.ChangeRecordsSpecialistsMetadata do
  use Ecto.Migration

  def change do
    rename table("timelines"), :creator_id, to: :created_by_specialist_id

    alter table("timelines") do
      add :with_specialist_id, :bigint
    end
  end
end
