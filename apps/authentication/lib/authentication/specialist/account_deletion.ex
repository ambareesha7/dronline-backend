defmodule Authentication.Specialist.AccountDeletion do
  use Postgres.Schema
  use Postgres.Service

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "specialist_account_deletions" do
    field :specialist_id, :integer
    field :status, Ecto.Enum, values: [:pending, :deleted], default: :pending

    timestamps()
  end

  @spec create(map) :: {:ok, %__MODULE__{}} | {:error, Ecto.Changeset.t()}
  def create(params) do
    %__MODULE__{}
    |> cast(params, [:specialist_id])
    |> validate_required([:specialist_id])
    |> unique_constraint(:specialist_id)
    |> Repo.insert()
  end

  @spec fetch_all :: {:ok, list(%__MODULE__{})}
  def fetch_all do
    __MODULE__
    |> Repo.fetch_all()
  end
end
