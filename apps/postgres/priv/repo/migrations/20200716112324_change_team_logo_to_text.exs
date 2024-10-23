defmodule Postgres.Repo.Migrations.ChangeTeamLogoToText do
  use Ecto.Migration

  def change do
    alter table(:specialist_teams) do
      modify(:logo_url, :text)
    end
  end
end
