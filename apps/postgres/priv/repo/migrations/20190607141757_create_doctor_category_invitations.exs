defmodule Postgres.Repo.Migrations.CreatePendingInvitationsForSpecialist do
  use Ecto.Migration

  def change do
    create table(:doctor_category_invitations, primary_key: false) do
      add :call_id, :string, primary_key: true, null: false
      add :category_id, :integer, primary_key: true, null: false

      add :invited_by_specialist_id, references(:specialists), null: false
      add :patient_id, references(:patients), null: false
      add :record_id, references(:timelines), null: false
      add :session_id, :string, null: false

      timestamps()
    end
  end
end
