defmodule Visits.Visit.Payment do
  @moduledoc """
  Visits' payments. Payment is assigned to a team for payout purposes.
  """

  use Postgres.Schema
  use Postgres.Service

  import Ecto.Query

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "visit_payments" do
    field :visit_id, :integer
    field :patient_id, :integer
    field :specialist_id, :integer
    field :team_id, :integer
    field :transaction_reference, :string
    field :payment_method, Ecto.Enum, values: [:telr, :external]
    field :price, Money.Ecto.Composite.Type

    timestamps()
  end

  @required [:visit_id, :patient_id, :specialist_id, :payment_method, :price]
  @fields @required ++ [:team_id, :transaction_reference]

  def changeset(struct, params) do
    struct
    |> cast(params, @fields)
    |> validate_required(@required)
  end

  def by_visit_id(record_id) do
    __MODULE__
    |> where(visit_id: ^record_id)
    |> Repo.one()
  end
end
