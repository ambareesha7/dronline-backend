defmodule SpecialistProfile.Insurances.Provider do
  use Postgres.Schema
  use Postgres.Service

  alias __MODULE__

  schema "insurance_providers" do
    field :name, :string
    field :country_id, :string

    many_to_many :specialists, SpecialistProfile.Specialist,
      join_through: "specialists_insurance_providers",
      on_delete: :delete_all

    timestamps()
  end

  @doc """
  Returns insurance providers which id is in given array
  """
  @spec fetch_by_ids([pos_integer]) :: {:ok, [%Provider{}]}
  def fetch_by_ids(ids) do
    Provider
    |> where([p], p.id in ^ids)
    |> Repo.fetch_all()
  end

  @doc """
  Returns insurance providers assigned to specialist
  """
  @spec fetch_by_specialist_id(pos_integer) :: {:ok, [%Provider{}]}
  def fetch_by_specialist_id(specialist_id) do
    Provider
    |> join(:inner, [p], s in assoc(p, :specialists))
    |> where([p, s], s.id == ^specialist_id)
    |> Repo.fetch_all()
  end
end
