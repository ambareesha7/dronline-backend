defmodule Calls.FamilyMemberInvitation do
  use Postgres.Schema
  use Postgres.Service

  @primary_key {:id, :string, autogenerate: false}
  schema "family_member_invitations" do
    field :call_id, :string
    field :name, :string
    field :session_id, :string
    field :session_token, :string
    field :patient_id, :integer
    field :phone_number, :string

    timestamps()
  end

  @spec fetch_by_id(pos_integer) :: {:ok, %__MODULE__{}} | {:error, :not_found}
  def fetch_by_id(id) do
    __MODULE__
    |> where(id: ^id)
    |> Repo.fetch_one()
    |> case do
      {:ok, invitation} -> {:ok, invitation}
      error -> error
    end
  end

  @fields [:call_id, :name, :session_id, :patient_id, :phone_number, :session_token]

  @spec create(map) :: {:ok, %__MODULE__{}} | {:error, Ecto.Changeset.t()}
  def create(params) do
    %__MODULE__{}
    |> cast(params, @fields)
    |> validate_required(@fields)
    |> put_change(:id, generate_id())
    |> Repo.insert()
  end

  defp generate_id do
    6
    |> :crypto.strong_rand_bytes()
    |> Base.url_encode64(padding: false)
  end
end
