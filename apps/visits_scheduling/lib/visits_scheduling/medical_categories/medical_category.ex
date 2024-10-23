defmodule VisitsScheduling.MedicalCategories.MedicalCategory do
  use Postgres.Schema
  use Postgres.Service

  alias __MODULE__

  schema "medical_categories" do
    field :name, :string
    field :image_url, :string
    field :what_we_treat_url, :string
    field :position, :integer
    field :disabled, :boolean
    field :icon_url, :string
    field :visit_type, Ecto.Enum, values: [:ONLINE, :IN_OFFICE, :BOTH], default: :BOTH

    belongs_to :parent_category, MedicalCategory

    timestamps()
  end

  @doc """
  Fetches root categories
  """
  @spec fetch_root :: {:ok, [%MedicalCategory{}]}
  def fetch_root do
    MedicalCategory
    |> where([mc], is_nil(mc.parent_category_id) and mc.disabled == false)
    |> order_by([:position])
    |> Repo.fetch_all()
  end

  @doc """
  Fetches single category by its id
  """
  @spec fetch_by_id(pos_integer | String.t()) :: {:ok, %MedicalCategory{}} | {:error, :not_found}
  def fetch_by_id(id) do
    MedicalCategory
    |> where(id: ^id)
    |> order_by([:id])
    |> Repo.fetch_one()
  end

  @doc """
  Fetches subcategories by parent_id
  """
  @spec fetch_subcategories(pos_integer | String.t()) :: {:ok, [%MedicalCategory{}]}
  def fetch_subcategories(parent_id) do
    MedicalCategory
    |> where(parent_category_id: ^parent_id, disabled: false)
    |> order_by(asc: :name)
    |> Repo.fetch_all()
  end
end
