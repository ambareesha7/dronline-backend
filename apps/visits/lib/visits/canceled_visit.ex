defmodule Visits.CanceledVisit do
  use Postgres.Schema
  use Postgres.Service

  alias Visits.PendingVisit

  @primary_key {:id, :binary_id, autogenerate: false}

  schema "canceled_visits" do
    field :start_time, :integer

    field :chosen_medical_category_id, :integer
    field :patient_id, :integer
    field :record_id, :integer
    field :specialist_id, :integer
    field :visit_type, Ecto.Enum, values: [:ONLINE, :IN_OFFICE, :US_BOARD]

    field :canceled_at, :utc_datetime_usec
    field :canceled_by, :string

    field :state, :string, virtual: true, default: "PREPARED"

    field :team_id, :integer

    timestamps()
  end

  @fields [
    :id,
    :chosen_medical_category_id,
    :patient_id,
    :record_id,
    :specialist_id,
    :start_time,
    :visit_type,
    :canceled_by
  ]

  def changeset(%PendingVisit{} = pending_visit, %{"canceled_by" => canceled_by} = _params) do
    params =
      pending_visit
      |> Map.from_struct()
      |> Map.merge(%{canceled_by: canceled_by})

    %__MODULE__{}
    |> cast(params, @fields ++ [:team_id])
    |> validate_required(@fields)
    |> validate_number(:chosen_medical_category_id, greater_than: 0)
    |> validate_number(:patient_id, greater_than: 0)
    |> validate_number(:record_id, greater_than: 0)
    |> validate_number(:specialist_id, greater_than: 0)
    |> validate_inclusion(:canceled_by, ["doctor", "patient"])
    |> unique_constraint(:_id,
      name: :canceled_visits_pkey,
      message: "selected visit is no longer available"
    )
  end

  @spec get(pos_integer) :: %__MODULE__{} | nil
  def get(id) do
    Repo.get(__MODULE__, id)
  end
end
