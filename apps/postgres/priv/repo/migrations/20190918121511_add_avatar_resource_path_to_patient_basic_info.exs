defmodule Postgres.Repo.Migrations.AddAvatarResourcePathToPatientBasicInfo do
  use Ecto.Migration

  def change do
    alter table(:patient_basic_infos) do
      add :avatar_resource_path, :string
    end
  end
end
