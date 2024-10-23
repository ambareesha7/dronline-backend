defmodule Postgres.Repo.Migrations.CreateTeamCredentials do
  use Ecto.Migration

  def change do
    create(table(:team_credentials)) do
      add(:identifier, :string, null: false)
      add(:encrypted_password, :string, null: false)
      add(:team_id, references(:specialist_teams), null: false)

      timestamps()
    end

    create(unique_index(:team_credentials, :identifier))
  end
end
