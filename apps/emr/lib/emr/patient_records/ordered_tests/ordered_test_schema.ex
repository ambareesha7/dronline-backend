defmodule EMR.PatientRecords.OrderedTest do
  use Postgres.Schema

  alias EMR.PatientRecords.MedicalLibrary.Test

  schema "ordered_tests" do
    field :bundle_id, :integer
    field :description, :string

    belongs_to :medical_test, Test

    timestamps()
  end
end
