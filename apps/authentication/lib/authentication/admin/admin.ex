defmodule Authentication.Admin do
  use Postgres.Schema
  use Postgres.Service

  import Mockery.Macro

  alias __MODULE__

  schema "administrators" do
    field :email, :string

    field :auth_token, :string

    field :password, :string, virtual: true
    field :password_hash, :string

    timestamps()
  end

  @fields [:email, :password]
  @required [:auth_token, :email, :password]
  defp create_changeset(struct, params) do
    struct
    |> cast(params, @fields)
    |> generate_token(:auth_token, 30)
    |> handle_password()
    |> validate_required(@required)
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:auth_token)
    |> unique_constraint(:email)
  end

  @spec create(map) :: {:ok, %Admin{}} | {:error, Ecto.Changeset.t()}
  def create(params) do
    %Admin{}
    |> create_changeset(params)
    |> Repo.insert()
  end

  @spec fetch_by_auth_token(String.t()) :: {:ok, %Admin{}} | {:error, :not_found}
  def fetch_by_auth_token(auth_token) do
    Admin
    |> where(auth_token: ^auth_token)
    |> Repo.fetch_one()
  end

  @spec fetch_by_email(String.t()) :: {:ok, %Admin{}} | {:error, :not_found}
  def fetch_by_email(email) do
    Admin
    |> where(email: ^email)
    |> Repo.fetch_one()
  end

  defp handle_password(changeset) do
    password = get_change(changeset, :password)

    changeset
    |> validate_password()
    |> validate_required([:password])
    |> case do
      %{valid?: true} = changeset ->
        changeset |> put_change(:password_hash, Pbkdf2.hash_pwd_salt(password))

      changeset ->
        changeset
    end
  end

  defp validate_password(changeset) do
    changeset
    |> validate_length(:password, min: 8)
    |> validate_format(:password, ~r/\d+/, message: "must contain at least 1 digit")
    |> validate_format(:password, ~r/[a-z]+/,
      message: "must contain at least 1 lowercase character"
    )
    |> validate_format(:password, ~r/[A-Z]+/,
      message: "must contain at least 1 uppercase character"
    )
    |> validate_format(:password, ~r/[ !@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/\?]+/,
      message: "must contain at least 1 special character"
    )
  end

  defp generate_token(changeset, field, size) do
    changeset |> put_change(field, mockable(Authentication.Random).url_safe(size))
  end
end
