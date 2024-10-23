defmodule Visits.FreeTimeslot do
  use Postgres.Schema

  embedded_schema do
    field :start_time, :integer
    field :visit_id, :string
    field :visit_type, Ecto.Enum, values: [:ONLINE, :IN_OFFICE, :BOTH, :US_BOARD]
  end

  @fields [:start_time, :visit_type]

  def changeset(struct, params) do
    struct
    |> cast(params, @fields)
    |> validate_required(@fields)
  end
end
