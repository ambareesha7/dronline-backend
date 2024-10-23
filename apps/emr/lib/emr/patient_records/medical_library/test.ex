defmodule EMR.PatientRecords.MedicalLibrary.Test do
  use Postgres.Schema
  use Postgres.Service

  alias EMR.PatientRecords.MedicalLibrary.TestsCategory

  @primary_key {:id, :integer, autogenerate: false}
  schema "medical_tests" do
    field :name, :string
    field :disabled, :boolean

    belongs_to :medical_tests_category,
               TestsCategory,
               foreign_key: :category_id
  end

  def fetch_by_categories do
    TestsCategory.fetch_query()
    |> join(:inner, [tc], t in assoc(tc, :tests),
      as: :test,
      on: t.category_id == tc.id and t.disabled == false
    )
    |> preload([test: t], tests: t)
    |> Repo.all()
  end
end
