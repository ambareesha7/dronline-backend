defmodule Admin.Medications.NewMedication do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "new_medications" do
    field :name, :string
    field :price, :float, default: 0.0
    field :currency, :string, default: "AED"

    timestamps()
  end

  @doc false
  def changeset(new_medication, attrs) do
    new_medication
    |> cast(attrs, [:name, :price, :currency])
    |> validate_required([:name])

    # |> unique_constraint(:name)
  end
end
