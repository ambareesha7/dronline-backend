defmodule Visits.Visit.Payment.Refund do
  @moduledoc """
  Refund for visits' payments. Refund can be done only for full payment price.
  """

  use Postgres.Schema
  use Postgres.Service

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "visit_payment_refunds" do
    field :requested_by, Ecto.Enum, values: [:patient, :specialist, :admin]
    field :requester_id, :integer

    belongs_to :payment, Visits.Visit.Payment

    timestamps()
  end

  @fields [:payment_id, :requested_by, :requester_id]

  def changeset(struct, params) do
    struct
    |> cast(params, @fields)
    |> validate_required(@fields)
  end

  def fetch_by_record_id(record_id) do
    __MODULE__
    |> join(:inner, [r], p in assoc(r, :payment))
    |> where([r, p], p.visit_id == ^record_id)
    |> preload([:payment])
    |> Repo.fetch_one()
  end
end
