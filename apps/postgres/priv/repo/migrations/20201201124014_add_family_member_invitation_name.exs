defmodule Postgres.Repo.Migrations.AddFamilyMemberInvitationName do
  use Ecto.Migration

  def change do
    alter table(:family_member_invitations) do
      add :name, :string, null: false
    end
  end
end
