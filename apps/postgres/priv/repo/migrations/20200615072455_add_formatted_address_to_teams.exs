defmodule Postgres.Repo.Migrations.AddFormattedAddressToTeams do
  use Ecto.Migration

  def change do
    alter table(:specialist_teams) do
      add(:formatted_address, :string)
    end
  end
end
