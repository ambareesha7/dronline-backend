defmodule Postgres.Repo.Migrations.CreateSentVisitRemindersTable do
  use Ecto.Migration

  def change do
    create table(:sent_visit_reminders) do
      add :visit_id, :bigint
      add :visit_start_time, :integer

      timestamps()
    end

    create index(:sent_visit_reminders, [:visit_start_time])
    create unique_index(:sent_visit_reminders, [:visit_id])
  end
end
