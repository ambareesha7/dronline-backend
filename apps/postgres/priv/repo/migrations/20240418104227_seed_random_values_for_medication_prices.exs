defmodule Postgres.Repo.Migrations.SeedRandomValuesForMedicationPrices do
  use Ecto.Migration

  import Ecto.Query

  alias EMR.PatientRecords.MedicalLibrary.Medication
  alias Postgres.Repo

  def up do
    # this will update price_aed with random value from 100 to 9999
    # update this migration before releasing to production with real prices
    Medication
    |> update(set: [price_aed: fragment("floor(random()*10000)")])
    |> Repo.update_all([])
  end

  def down do
    Medication
    |> update(set: [price_aed: nil])
    |> Repo.update_all([])
  end
end
