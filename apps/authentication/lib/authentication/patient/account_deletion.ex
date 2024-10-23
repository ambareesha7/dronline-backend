defmodule Authentication.Patient.AccountDeletion do
  use Postgres.Schema
  use Postgres.Service

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "patient_account_deletions" do
    field :patient_id, :integer
    field :status, Ecto.Enum, values: [:pending, :deleted], default: :pending

    timestamps()
  end

  @spec create(map) :: {:ok, %__MODULE__{}} | {:error, Ecto.Changeset.t()}
  def create(params) do
    %__MODULE__{}
    |> cast(params, [:patient_id])
    |> validate_required([:patient_id])
    |> unique_constraint(:patient_id)
    |> Repo.insert()
  end

  @spec fetch_all :: {:ok, list(%__MODULE__{})}
  def fetch_all do
    __MODULE__
    |> Repo.fetch_all()
  end
end
