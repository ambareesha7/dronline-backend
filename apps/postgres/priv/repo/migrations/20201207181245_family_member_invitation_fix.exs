defmodule Postgres.Repo.Migrations.FamilyMemberInvitationFix do
  use Ecto.Migration

  def up do
    alter table(:family_member_invitations) do
      modify :session_id, :text, null: false
      modify :session_token, :text, null: false
    end
  end

  def down, do: nil
end
