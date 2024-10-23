defmodule Postgres.Repo.Migrations.AddNameAndLogoUrlToTeams do
  use Ecto.Migration

  def change do
    alter table(:specialist_teams) do
      add(:name, :string)
      add(:logo_url, :string)
    end
  end
end
