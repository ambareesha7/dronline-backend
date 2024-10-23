defmodule Postgres.Repo.Migrations.CreateVitalsTable do
  use Ecto.Migration

  def change do
    create table(:vitals) do
      add :weight, :integer
      add :height, :integer

      add :systolic, :integer
      add :diastolic, :integer
      add :pulse, :integer

      add :ekg_file_url, :string

      add :timeline_id, references(:timelines), null: false
      add :user_id, references(:users), null: false
      add :nurse_id, references(:specialists), null: false

      timestamps()
    end

    create index(:vitals, [:timeline_id])
    create index(:vitals, [:user_id])
    create index(:vitals, [:nurse_id])
  end
end
