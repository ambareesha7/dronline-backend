defmodule PatientProfile.Address do
  use Postgres.Schema
  use Postgres.Service

  schema "patient_addresses" do
    field :additional_numbers, :string
    field :city, :string
    field :country, :string
    field :home_number, :string
    field :neighborhood, :string
    field :street, :string
    field :zip_code, :string

    field :patient_id, :integer

    timestamps()
  end

  @fields [:additional_numbers, :city, :country, :home_number, :neighborhood, :street, :zip_code]
  @required_fields [:city, :country, :home_number, :neighborhood, :street, :zip_code]
  defp changeset(struct, params) do
    struct
    |> cast(params, @fields)
    |> validate_required(@required_fields)
  end

  @spec get_by_patient_id(pos_integer) :: %__MODULE__{} | nil
  def get_by_patient_id(patient_id) do
    Repo.get_by(__MODULE__, patient_id: patient_id)
  end

  @doc """
  Creates new address or updates existing one for given patient_id
  """
  @spec update(map, pos_integer) :: {:ok, %__MODULE__{}} | {:error, Ecto.Changeset.t()}
  def update(params, patient_id) do
    address = get_by_patient_id(patient_id) || %__MODULE__{patient_id: patient_id}

    address
    |> changeset(params)
    |> Repo.insert_or_update()
  end
end
