defmodule Visits.MedicalCategory do
  use Postgres.Schema
  use Postgres.Service

  alias __MODULE__

  schema "medical_categories" do
    field :name, :string
    field :parent_category_id, :integer
  end

  @doc """
  Fetches single category by its id
  """
  @spec fetch(pos_integer | String.t()) :: {:ok, %MedicalCategory{}} | {:error, :not_found}
  def fetch(id) do
    MedicalCategory
    |> where(id: ^id)
    |> Repo.fetch_one()
  end

  def fetch_us_board_medical_category do
    MedicalCategory
    |> where(name: "U.S Board Second Opinion")
    |> Repo.fetch_one()
  end
end
