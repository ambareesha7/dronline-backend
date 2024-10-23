defmodule SpecialistProfile.Bio.EducationEntry do
  use Postgres.Schema

  embedded_schema do
    field :school, :string
    field :field_of_study, :string
    field :degree, :string
    field :start_year, :integer
    field :end_year, :integer
  end

  @fields [:degree, :field_of_study, :school, :start_year, :end_year]
  @required_fields [:degree, :field_of_study, :school, :start_year]

  def changeset(struct, params) do
    struct
    |> cast(params, @fields, empty_values: ["", 0])
    |> validate_required(@required_fields)
  end
end
