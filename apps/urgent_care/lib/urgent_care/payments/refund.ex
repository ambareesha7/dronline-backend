defmodule UrgentCare.Payments.Refund do
  use Postgres.Schema
  use Postgres.Service

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "urgent_care_request_payments_refunds" do
    field :reason, Ecto.Enum, values: [:canceled_by_patient, :canceled_automatically]

    belongs_to :payment, UrgentCare.Payments.Payment

    timestamps()
  end

  @fields [:payment_id, :reason]

  def changeset(struct, params) do
    struct
    |> cast(params, @fields)
    |> validate_required(@fields)
  end
end
