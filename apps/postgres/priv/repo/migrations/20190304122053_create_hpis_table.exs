defmodule Postgres.Repo.Migrations.CreateHPIsTable do
  use Ecto.Migration

  def change do
    create table(:hpis) do
      add :timeline_id, references(:timelines), null: false
      add :encoded_form, :binary

      timestamps()
    end

    create unique_index(:hpis, ["timeline_id"])
  end
end
