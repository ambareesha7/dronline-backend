defmodule Postgres.Repo.Migrations.AddMedicalTitleToSpecialistBasicInfo do
  use Ecto.Migration

  def change do
    alter table(:specialist_basic_infos) do
      add :medical_title, :string, default: "UNKNOWN_MEDICAL_TITLE"
    end
  end
end
