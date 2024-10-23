defmodule Postgres.Repo.Migrations.CreateDoctorInvitationTimelineItemType do
  use Ecto.Migration

  def change do
    create table(:doctor_invitations) do
      add :medical_category_id, references(:medical_categories)

      add :specialist_id, references(:specialists)
      add :timeline_id, references(:timelines)
      add :user_id, references(:users)

      timestamps()
    end

    create index(:doctor_invitations, [:specialist_id])
    create index(:doctor_invitations, [:timeline_id])
    create index(:doctor_invitations, [:user_id])

    alter table(:timeline_items) do
      add :doctor_invitation_id, references(:doctor_invitations), null: true
    end

    create index(:timeline_items, [:doctor_invitation_id])
  end
end
