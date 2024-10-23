defmodule EMR.Medications.MedicationOrder do
  use Postgres.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "medication_orders" do
    field :delivery_address, :string

    field :delivery_status, Ecto.Enum,
      values: [:none, :delivered, :cancelled, :in_progress, :assigned],
      default: :none

    field :payment_status, Ecto.Enum,
      values: [:none, :paid, :declined, :pending, :failed, :initiated, :authorised],
      default: :none

    field :patient_id, :integer
    field :medications_bundle_payments_id, :binary_id
    belongs_to :medications_bundle, EMR.Medications.MedicationsBundle, type: :integer

    timestamps()
  end

  @fields [
    :delivery_address,
    :delivery_status,
    :payment_status,
    :patient_id,
    :medications_bundle_id,
    :medications_bundle_payments_id
  ]
  @doc false
  def changeset(medication_order, attrs) do
    medication_order
    |> cast(attrs, @fields)
    |> validate_required([:medications_bundle_id])
  end
end
