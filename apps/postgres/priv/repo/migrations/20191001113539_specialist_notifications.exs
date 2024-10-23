defmodule Postgres.Repo.Migrations.SpecialistNotifications do
  use Ecto.Migration

  def change do
    create table(:specialist_notifications, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :for_specialist_id, :bigint
      add :read, :boolean, default: false

      add :timeline_item_comment_id, :binary_id

      timestamps(type: :utc_datetime_usec, updated_at: false)
    end

    create index(:specialist_notifications, [:for_specialist_id, :read])
  end
end
