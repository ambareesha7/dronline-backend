defmodule Visits.EndedVisit do
  use Postgres.Schema
  use Postgres.Service

  @primary_key {:id, :binary_id, autogenerate: false}

  schema "ended_visits" do
    field :start_time, :integer

    field :chosen_medical_category_id, :integer
    field :patient_id, :integer
    field :record_id, :integer
    field :specialist_id, :integer

    field :team_id, :integer

    field :state, :string, virtual: true, default: "ENDED"

    field :visit_type, Ecto.Enum, values: [:ONLINE, :IN_OFFICE, :US_BOARD]

    timestamps()
  end

  @fields [
    :id,
    :chosen_medical_category_id,
    :patient_id,
    :record_id,
    :specialist_id,
    :start_time,
    :visit_type
  ]

  defp changeset(%__MODULE__{} = struct, params) do
    struct
    |> cast(params, @fields ++ [:team_id])
    |> validate_required(@fields)
    |> validate_number(:chosen_medical_category_id, greater_than: 0)
    |> validate_number(:patient_id, greater_than: 0)
    |> validate_number(:record_id, greater_than: 0)
    |> validate_number(:specialist_id, greater_than: 0)
    |> unique_constraint(:_id,
      name: :ended_visits_pkey,
      message: "selected visit is no longer available"
    )
  end

  @spec create(%Visits.PendingVisit{}) :: {:ok, %__MODULE__{}} | {:error, Ecto.Changeset.t()}
  def create(%Visits.PendingVisit{} = pending_visit) do
    params = Map.from_struct(pending_visit)

    %__MODULE__{}
    |> changeset(params)
    |> Repo.insert()
  end

  @spec fetch_paginated_for_specialist(pos_integer, map) :: {:ok, [%__MODULE__{}], String.t()}
  def fetch_paginated_for_specialist(specialist_id, params) do
    {:ok, result, next_token} =
      __MODULE__
      |> where(specialist_id: ^specialist_id)
      |> where(^Postgres.Option.next_token(params, :start_time, :desc))
      |> order_by(desc: :start_time)
      |> Repo.fetch_paginated(params, :start_time)

    {:ok, result, to_string(next_token)}
  end
end
