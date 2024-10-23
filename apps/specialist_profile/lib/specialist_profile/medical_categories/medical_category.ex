defmodule SpecialistProfile.MedicalCategories.MedicalCategory do
  use Postgres.Schema
  use Postgres.Service

  alias __MODULE__

  schema "medical_categories" do
    field :name, :string
    field :disabled, :boolean
    field :position, :integer

    belongs_to :parent_category, MedicalCategory

    many_to_many :specialists, SpecialistProfile.Specialist,
      join_through: "specialists_medical_categories"

    timestamps()
  end

  @doc """
  Return all medical categories
  """
  @spec fetch_all() :: {:ok, [%MedicalCategory{}]}
  def fetch_all do
    MedicalCategory
    # temporary commented for US Board second opinion testing,
    # uncomment when we add categories management in admin panel
    # |> where([mc], mc.disabled == false)
    |> order_by([:position])
    |> Repo.fetch_all()
  end

  @doc """
  Returns medical categories assigned to doctor
  """
  @spec fetch_for_doctor(pos_integer) :: {:ok, [%MedicalCategory{}]}
  def fetch_for_doctor(doctor_id) do
    MedicalCategory
    |> join(:inner, [mc], s in assoc(mc, :specialists))
    |> where([mc, s], s.id == ^doctor_id and s.type in ["EXTERNAL"])
    # temporary commented for US Board second opinion testing,
    # uncomment when we add categories management in admin panel
    # |> where([mc], mc.disabled == false)
    |> order_by([:position])
    |> Repo.fetch_all()
  end

  @doc """
  Returns medical categories which id is in given array
  """
  @spec fetch_by_ids([pos_integer]) :: {:ok, [%MedicalCategory{}]}
  def fetch_by_ids(ids) do
    MedicalCategory
    |> where([mc], mc.id in ^ids)
    # temporary commented for US Board second opinion testing,
    # uncomment when we add categories management in admin panel
    # |> where([mc], mc.disabled == false)
    |> order_by([:position])
    |> Repo.fetch_all()
  end

  @spec get_medical_categories_for_specialists([pos_integer]) :: %{
          optional(pos_integer) => medical_category :: [%{id: pos_integer, name: String.t()}]
        }
  def get_medical_categories_for_specialists(specialist_ids) do
    categories_names_map = MedicalCategory |> Repo.all() |> Map.new(&{&1.id, &1.name})

    specialist_ids
    |> get_specialists_medical_categories()
    |> Enum.map(fn {specialist_id, medical_category_id} ->
      {specialist_id, %{id: medical_category_id, name: categories_names_map[medical_category_id]}}
    end)
    |> Enum.group_by(
      fn {specialist_id, _medical_category} -> specialist_id end,
      fn {_specialist_id, medical_category} -> medical_category end
    )
  end

  defp get_specialists_medical_categories(specialist_ids) do
    "specialists_medical_categories"
    |> where([smc], smc.specialist_id in ^specialist_ids)
    |> select([smc], {smc.specialist_id, smc.medical_category_id})
    |> Repo.all()
  end

  @spec get_specialist_ids_for_medical_category(pos_integer) :: [pos_integer]
  def get_specialist_ids_for_medical_category(medical_category_id) do
    "specialists_medical_categories"
    |> where(medical_category_id: ^medical_category_id)
    |> order_by(asc: :specialist_id)
    |> select([smc], smc.specialist_id)
    |> Repo.all()
  end
end
