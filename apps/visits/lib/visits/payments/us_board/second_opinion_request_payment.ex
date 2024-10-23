defmodule Visits.USBoard.SecondOpinionRequestPayment do
  @moduledoc """
  Visits' payments. Payment is assigned to a team for payout purposes.
  """

  use Postgres.Schema
  use Postgres.Service

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "us_board_second_opinion_request_payments" do
    field :patient_id, :integer
    field :specialist_id, :integer
    field :team_id, :integer
    field :visit_id, :integer
    field :transaction_reference, :string
    field :payment_method, Ecto.Enum, values: [:telr]
    field :price, Money.Ecto.Composite.Type

    belongs_to :us_board_second_opinion_request, Visits.USBoard.SecondOpinionRequest,
      foreign_key: :us_board_second_opinion_request_id,
      type: :binary_id

    timestamps()
  end

  @required [
    :us_board_second_opinion_request_id,
    :payment_method,
    :price,
    :transaction_reference
  ]
  @fields @required ++ [:patient_id, :specialist_id, :team_id, :visit_id]

  def changeset(struct, params) do
    struct
    |> cast(params, @fields)
    |> validate_required(@required)
  end

  def fetch_by_us_board_second_opinion_request_id(request_id) do
    __MODULE__
    |> where(us_board_second_opinion_request_id: ^request_id)
    |> Repo.one()
  end
end
