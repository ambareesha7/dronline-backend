defmodule EMR.Tests.OrderedTestsBundle do
  use Postgres.Schema
  use Postgres.Service

  alias EMR.Tests.OrderedTest

  schema "ordered_tests_bundles" do
    field :specialist_id, :integer
    field :patient_id, :integer
    field :timeline_id, :integer

    has_many :tests, OrderedTest,
      foreign_key: :bundle_id,
      references: :id

    timestamps()
  end
end
