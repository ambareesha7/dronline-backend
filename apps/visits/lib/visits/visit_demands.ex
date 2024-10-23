defmodule Visits.Demands do
  use Postgres.Schema
  use Postgres.Service

  schema "visit_demands" do
    field :patient_id, :integer
    field :specialist_id, :integer
    field :medical_category_id, :integer

    timestamps()
  end

  defp create_changeset(struct, params) do
    struct
    |> cast(params, [:patient_id, :medical_category_id, :specialist_id])
    |> handle_params_combination()
  end

  defp handle_params_combination(changeset) do
    medical_category_id = get_change(changeset, :medical_category_id)

    if is_nil(medical_category_id) do
      changeset
      |> validate_required([:patient_id, :specialist_id])
    else
      changeset
      |> validate_required([:patient_id, :medical_category_id])
    end
  end

  @doc """
  Creates visit demand for a patient.
  It can be created for a specialist or for a category.
  We are eliminating duplicates.
  """
  @spec create(map()) :: {:ok, %__MODULE__{}} | {:error, Ecto.Changeset.t()}
  def create(params) do
    {:ok, patient_visit_demands} = fetch_patient_visit_demands(params.patient_id)

    if existing_record = already_exists?(params, patient_visit_demands) do
      {:ok, existing_record}
    else
      %__MODULE__{}
      |> create_changeset(params)
      |> Repo.insert()
    end
  end

  @spec fetch_patient_visit_demands(pos_integer) :: {:ok, [%__MODULE__{}]}
  def fetch_patient_visit_demands(patient_id) do
    __MODULE__
    |> where(patient_id: ^patient_id)
    |> Repo.fetch_all()
  end

  @spec fetch_visit_demands_for_categories([pos_integer]) :: {:ok, [%__MODULE__{}]}
  def fetch_visit_demands_for_categories(medical_category_ids) do
    __MODULE__
    |> where([vd], vd.medical_category_id in ^medical_category_ids)
    |> Repo.fetch_all()
  end

  @spec fetch_visit_demands_for_specialist(pos_integer) :: {:ok, [%__MODULE__{}]}
  def fetch_visit_demands_for_specialist(specialist_id) do
    __MODULE__
    |> where([vd], vd.specialist_id == ^specialist_id)
    |> Repo.fetch_all()
  end

  @spec delete_by_ids([pos_integer]) :: :ok
  def delete_by_ids(visit_demand_ids) do
    _ =
      __MODULE__
      |> where([vd], vd.id in ^visit_demand_ids)
      |> Repo.delete_all()

    :ok
  end

  defp already_exists?(%{specialist_id: specialist_id}, patient_visit_demands) do
    patient_visit_demands
    |> Enum.find(fn demand ->
      demand.specialist_id == specialist_id
    end)
  end

  defp already_exists?(%{medical_category_id: medical_category_id}, patient_visit_demands) do
    patient_visit_demands
    |> Enum.find(fn demand ->
      demand.medical_category_id == medical_category_id
    end)
  end
end
