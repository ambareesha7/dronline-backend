defmodule Postgres.Repo.Migrations.AddTeamIdToCallInvitations do
  use Ecto.Migration

  def change do
    alter(table(:doctor_category_invitations)) do
      add :team_id, :integer
    end

    create(index(:doctor_category_invitations, :team_id))
  end
end
