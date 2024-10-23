defmodule Admin.Newsletter.Subscriber do
  use Postgres.Schema
  use Postgres.Service

  alias __MODULE__

  schema "newsletter_subscribers" do
    field :email, :string
    field :phone_number, :string

    timestamps()
  end

  @fields [:email, :phone_number]
  @required [:email]
  defp create_changeset(struct, params) do
    struct
    |> cast(params, @fields)
    |> validate_required(@required)
    |> validate_format(:email, ~r/@/)
    # accepts a phone number which contatins '+' followed by digits
    |> validate_format(:phone_number, ~r/\+\d+/)
    |> unique_constraint(:email)
    |> unique_constraint(:phone_number)
  end

  @spec create(String.t(), String.t()) :: {:ok, %Subscriber{}} | {:error, Ecto.Changeset.t()}
  def create(email, phone_number) do
    params = %{
      email: email,
      phone_number: phone_number
    }

    %Subscriber{}
    |> create_changeset(params)
    |> Repo.insert()
  end
end
