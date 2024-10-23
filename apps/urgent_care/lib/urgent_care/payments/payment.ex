defmodule UrgentCare.Payments.Payment do
  use Postgres.Schema
  use Postgres.Service

  alias UrgentCare.Request

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "urgent_care_request_payments" do
    field :transaction_reference, :string
    field :payment_method, Ecto.Enum, values: [:telr]
    field :price, Money.Ecto.Composite.Type

    belongs_to :urgent_care_request, Request, foreign_key: :urgent_care_request_id

    timestamps()
  end

  @fields [:transaction_reference, :payment_method, :price]
  @required [:transaction_reference, :payment_method, :price]
  def changeset(struct, params) do
    price = Money.new(params.price.amount, parse_currency(params.price.currency))
    params = Map.put(params, :price, price)

    struct
    |> cast(params, @fields)
    |> validate_required(@required)
  end

  def fetch_by_urgent_care_patient_record_id(patient_record_id) do
    __MODULE__
    |> join(:left, [p], r in assoc(p, :urgent_care_request))
    |> where([p, r], r.patient_record_id == ^patient_record_id)
    |> where([p, r], is_nil(r.canceled_at))
    |> Repo.one()
  end

  defp parse_currency("USD"), do: :USD
  defp parse_currency("AED"), do: :AED
  defp parse_currency("INR"), do: :INR
  defp parse_currency(any) when is_atom(any), do: any
end
