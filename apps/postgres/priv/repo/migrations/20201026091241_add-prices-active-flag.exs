defmodule :"Elixir.Postgres.Repo.Migrations.Add-prices-active-flag" do
  use Ecto.Migration

  def change do
    alter table(:specialists_medical_categories) do
      add :prices_enabled, :boolean, default: false, null: false
    end
  end
end
