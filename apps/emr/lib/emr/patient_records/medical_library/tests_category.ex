defmodule EMR.PatientRecords.MedicalLibrary.TestsCategory do
  use Postgres.Schema
  use Postgres.Service

  alias EMR.PatientRecords.MedicalLibrary.Test

  @primary_key {:id, :integer, autogenerate: false}
  schema "medical_tests_categories" do
    field :name, :string
    field :disabled, :boolean

    has_many :tests, Test,
      foreign_key: :category_id,
      references: :id
  end

  def fetch_query do
    __MODULE__
    |> where([tc], tc.disabled == false)
  end
end
