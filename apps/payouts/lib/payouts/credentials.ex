defmodule Payouts.Credentials do
  use Postgres.Schema
  use Postgres.Service

  @primary_key {:specialist_id, :integer, autogenerate: false}
  schema "specialist_payouts_credentials" do
    field :iban, :string
    field :name, :string
    field :address, :string
    field :bank_name, :string
    field :bank_address, :string
    field :bank_swift_code, :string
    field :bank_routing_number, :string

    timestamps()
  end

  @required_fields [
    :specialist_id,
    :iban,
    :name,
    :bank_name,
    :bank_swift_code
  ]
  @fields @required_fields ++
            [
              :address,
              :bank_address,
              :bank_routing_number
            ]
  defp changeset(struct, params) do
    struct
    |> cast(params, @fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:specialist_id)
  end

  @spec fetch_by_specialist_id(pos_integer) :: {:ok, %__MODULE__{} | nil}
  def fetch_by_specialist_id(specialist_id) do
    result =
      __MODULE__
      |> where(specialist_id: ^specialist_id)
      |> Repo.one()

    {:ok, result}
  end

  @spec update(map, pos_integer) :: {:ok, %__MODULE__{}} | {:error, Ecto.Changeset.t()}
  def update(params, specialist_id) do
    {:ok, credentials} = fetch_by_specialist_id(specialist_id)

    (credentials || %__MODULE__{specialist_id: specialist_id})
    |> changeset(params)
    |> Repo.insert_or_update()
  end
end
