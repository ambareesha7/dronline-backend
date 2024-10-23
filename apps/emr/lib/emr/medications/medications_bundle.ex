defmodule EMR.Medications.MedicationsBundle do
  use Postgres.Schema

  alias EMR.PatientRecords.MedicationsBundle.Medication

  schema "medications_bundles" do
    field :specialist_id, :integer
    field :patient_id, :integer

    embeds_many :medications, Medication, on_replace: :delete

    timestamps()
  end
end
