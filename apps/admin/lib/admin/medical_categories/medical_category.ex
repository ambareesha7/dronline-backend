defmodule Admin.MedicalCategories.MedicalCategory do
  use Postgres.Schema
  use Postgres.Service

  schema "medical_categories" do
    field :parent_category_id, :integer
    field :name, :string
    field :disabled, :boolean
    field :position, :integer

    timestamps()
  end

  def fetch_all do
    __MODULE__
    |> order_by([:position])
    |> Repo.fetch_all()
  end

  @fields [:name, :disabled, :position]
  def changeset(medical_category, attrs) do
    medical_category
    |> cast(attrs, @fields)
    |> validate_required([:name])
    |> validate_inclusion(:disabled, [true, false])
    |> validate_number(:position, greater_than_or_equal_to: 0)
  end

  def update(id, attrs) do
    case Repo.fetch(__MODULE__, id) do
      {:ok, category} ->
        category |> __MODULE__.changeset(attrs) |> Repo.update()

      {:error, :not_found} ->
        {:error, :not_found}
    end
  end
end
