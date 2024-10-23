defmodule Postgres.Repo.Migrations.RemovePatientBloodPressures do
  use Ecto.Migration

  def change do
    drop table("patient_blood_pressures")
  end
end
