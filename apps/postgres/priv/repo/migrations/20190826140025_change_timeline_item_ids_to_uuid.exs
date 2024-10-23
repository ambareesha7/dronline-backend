defmodule Postgres.Repo.Migrations.ChangeTimelineItemIdsToUuid do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION \"uuid-ossp\";"

    execute """
    ALTER TABLE timeline_items
      ALTER COLUMN id DROP DEFAULT,
      ALTER COLUMN id SET DATA TYPE UUID USING (uuid_generate_v4());
    """
  end
end
