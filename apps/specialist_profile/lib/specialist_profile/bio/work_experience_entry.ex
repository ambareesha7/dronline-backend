defmodule SpecialistProfile.Bio.WorkExperienceEntry do
  use Postgres.Schema

  embedded_schema do
    field :institution, :string
    field :position, :string
    field :start_year, :integer
    field :end_year, :integer
  end

  @fields [:institution, :position, :start_year, :end_year]
  @required_fields [:institution, :position, :start_year]

  def changeset(struct, params) do
    struct
    |> cast(params, @fields, empty_values: ["", 0])
    |> validate_required(@required_fields)
  end
end
