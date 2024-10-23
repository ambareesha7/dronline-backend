defmodule Postgres.Repo.Migrations.FamilyMemberInvitation do
  use Ecto.Migration

  def change do
    create table(:family_member_invitations, primary_key: false) do
      add :id, :string, null: false, primary_key: true
      add :call_id, :string, null: false
      add :session_id, :string, null: false
      add :patient_id, :bigint, null: false
      add :session_token, :string, null: false
      add :phone_number, :string, null: false

      timestamps()
    end
  end
end
