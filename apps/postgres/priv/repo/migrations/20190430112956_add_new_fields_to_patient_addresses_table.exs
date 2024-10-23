defmodule Postgres.Repo.Migrations.AddNewFieldsToPatientAddressesTable do
  use Ecto.Migration

  def change do
    alter table(:patient_addresses) do
      add :additional_numbers, :string
      add :neighborhood, :string
    end
  end
end
