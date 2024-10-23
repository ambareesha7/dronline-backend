defmodule EMR.Tests.OrderedTest do
  use Postgres.Schema
  use Postgres.Service

  alias EMR.PatientRecords.MedicalLibrary.Test
  alias EMR.Tests.OrderedTestsBundle

  schema "ordered_tests" do
    field :description, :string

    belongs_to :medical_test, Test

    belongs_to :ordered_tests_bundle,
               OrderedTestsBundle,
               foreign_key: :bundle_id

    timestamps()
  end
end
