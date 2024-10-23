defmodule PatientProfile.Schema do
  use Postgres.Schema
  use Postgres.Service

  schema "patients" do
    field :phone_number, :string

    timestamps()
  end

  @spec create(String.t()) :: {:ok, %__MODULE__{}}
  def create(phone_number) do
    Repo.insert(%__MODULE__{phone_number: phone_number})
  end

  @spec fetch_by_id(pos_integer) :: {:ok, %__MODULE__{}} | {:error, :not_found}
  def fetch_by_id(id) do
    Repo.fetch(__MODULE__, id)
  end

  @spec get_by_ids([pos_integer]) :: [%__MODULE__{}]
  def get_by_ids(ids) do
    __MODULE__
    |> where([p], p.id in ^ids)
    |> Repo.all()
  end

  def get_patient_details(id) do
    query =
      from p in __MODULE__,
        join: pbi in PatientProfile.BasicInfo,
        on: p.id == pbi.patient_id,
        where: p.id == ^id,
        # add more fields as we need
        select: %{
          first_name: pbi.first_name,
          last_name: pbi.last_name,
          phone_nmber: p.phone_number,
          email: pbi.email
        }

    Repo.fetch(query, id)
  end
end
