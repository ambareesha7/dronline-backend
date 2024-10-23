defmodule Postgres.Repo.Migrations.AddSpecialistBios do
  use Ecto.Migration

  def change do
    create table(:specialist_bios, primary_key: false) do
      add :specialist_id, :bigint, primary_key: true

      add :bio, :text
      add :education, :jsonb, default: "[]"
      add :work_experience, :jsonb, default: "[]"

      timestamps()
    end
  end
end
