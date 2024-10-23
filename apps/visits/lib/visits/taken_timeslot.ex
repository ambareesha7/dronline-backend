defmodule Visits.TakenTimeslot do
  use Postgres.Schema

  @primary_key {:id, :binary_id, autogenerate: false}

  embedded_schema do
    field :start_time, :integer

    field :patient_id, :integer
    field :record_id, :integer
    field :visit_id, :binary_id
    field :visit_type, Ecto.Enum, values: [:ONLINE, :IN_OFFICE, :US_BOARD]
  end

  @fields [:id, :start_time, :patient_id, :record_id, :visit_id, :visit_type]

  def changeset(struct, params) do
    struct
    |> cast(params, @fields)
    |> validate_required(@fields)
    |> validate_number(:patient_id, greater_than: 0)
    |> validate_number(:record_id, greater_than: 0)
  end
end
