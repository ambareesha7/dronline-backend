defmodule Triage.PatientLocationAddress do
  use Postgres.Schema

  @derive Jason.Encoder
  @primary_key false

  embedded_schema do
    field :additional_numbers, :string
    field :building_number, :string
    field :city, :string
    field :country, :string
    field :district, :string
    field :postal_code, :string
    field :street_name, :string
  end

  @optional_fields [:additional_numbers, :district]
  @required_fields [:building_number, :city, :country, :postal_code, :street_name]

  def changeset(struct, params) do
    struct
    |> cast(params, @required_fields)
    |> cast(params, @optional_fields, empty_values: [])
    |> validate_required(@required_fields)
  end
end
