defmodule Postgres.Repo.Migrations.CreateSentVisitRemindersV2 do
  use Ecto.Migration

  def change do
    create table(:sent_visit_reminders_v2) do
      add :visit_id, :binary_id
      add :visit_start_time, :integer

      timestamps()
    end

    create index(:sent_visit_reminders_v2, [:visit_start_time])
    create unique_index(:sent_visit_reminders_v2, [:visit_id])
  end
end
