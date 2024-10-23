defmodule Postgres.Repo.Migrations.AddUniqueIndexesForPatientBasicInfos do
  use Ecto.Migration

  def change do
    drop index(:patient_basic_infos, [:patient_id])
    create unique_index(:patient_basic_infos, [:patient_id])
  end
end
