defmodule EMR.Medications.Payment do
  use Postgres.Schema
  use Postgres.Service

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "medications_bundle_payments" do
    field :transaction_reference, :string
    field :payment_method, Ecto.Enum, values: [:TELR]
    field :price, Money.Ecto.Composite.Type

    belongs_to :medications_bundle, EMR.Medications.MedicationsBundle,
      foreign_key: :medications_bundle_id,
      type: :integer

    belongs_to :medication_order, EMR.Medications.MedicationOrder, type: :binary_id

    timestamps()
  end

  @fields [
    :medications_bundle_id,
    :medication_order_id,
    :price
  ]
  def changeset(struct, params) do
    struct
    |> cast(params, @fields ++ [:payment_method, :transaction_reference])
    |> validate_required(@fields)
  end

  def uppdate_changeset(struct, params) do
    struct
    |> change(params)
  end
end
