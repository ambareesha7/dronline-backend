defmodule Postgres.Repo.Migrations.AddOwnerIdToTeams do
  use Ecto.Migration

  def change do
    alter table(:specialist_teams) do
      add(:owner_id, :integer)
    end

    create(index(:specialist_teams, :owner_id))
  end
end
