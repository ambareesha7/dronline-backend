defmodule Postgres.Repo.Migrations.CreateTeamInvitations do
  use Ecto.Migration

  def change do
    create(table(:team_invitations)) do
      add :team_id, :integer
      add :specialist_id, :integer

      timestamps()
    end

    create(unique_index(:team_invitations, [:specialist_id, :team_id]))
  end
end
