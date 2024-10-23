defmodule Admin.Medications.MedicalMedication do
  use Postgres.Schema
  use Postgres.Service

  schema "medical_medications" do
    field :name, :string
    field :price_aed, :integer

    timestamps()
  end
end
