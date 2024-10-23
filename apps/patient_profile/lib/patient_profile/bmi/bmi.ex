defmodule PatientProfile.BMI do
  use Postgres.Schema
  use Postgres.Service

  alias __MODULE__

  schema "patient_bmis" do
    field :height, :integer
    field :weight, :integer

    field :patient_id, :integer

    timestamps()
  end

  @fields [
    :height,
    :weight
  ]
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @fields)
    |> validate_required(@fields)
  end

  @doc """
  Fetches bmi based on patient_id.
  If patient doesn't have one yet then returns empty one.
  """
  @spec fetch_by_patient_id(pos_integer) :: {:ok, %BMI{}}
  def fetch_by_patient_id(patient_id) do
    BMI
    |> where(patient_id: ^patient_id)
    |> Repo.fetch_one()
    |> case do
      {:ok, bmi} -> {:ok, bmi}
      {:error, :not_found} -> {:ok, %BMI{patient_id: patient_id}}
    end
  end

  @doc """
  Creates new bmi or updates existing one for given patient_id
  """
  @spec update(map, pos_integer) :: {:ok, %BMI{}} | {:error, Ecto.Changeset.t()}
  def update(params, patient_id) do
    {:ok, bmi} = fetch_by_patient_id(patient_id)

    bmi
    |> changeset(params)
    |> Repo.insert_or_update()
  end
end
