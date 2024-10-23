defmodule Authentication.Specialist.PasswordChange do
  use Postgres.Schema
  use Postgres.Service

  alias __MODULE__
  alias Authentication.Specialist.ChangesetHelpers

  @hours_to_confirmation_token_expiration 12

  schema "specialist_password_changes" do
    field :password, :string, virtual: true
    field :password_hash, :string
    field :confirmation_token, :string
    field :expire_at, :naive_datetime_usec
    belongs_to :specialist, Authentication.Specialist

    timestamps()
  end

  defp create_changeset(struct, params) do
    struct
    |> cast(params, [:password])
    |> ChangesetHelpers.handle_password()
    |> ChangesetHelpers.generate_token(:confirmation_token, 20)
    |> put_token_expiration_datetime()
    |> unique_constraint(:confirmation_token)
  end

  defp put_token_expiration_datetime(changeset) do
    expiration_datetime =
      Timex.now()
      |> Timex.shift(hours: @hours_to_confirmation_token_expiration)
      |> Timex.to_naive_datetime()

    put_change(changeset, :expire_at, expiration_datetime)
  end

  @doc """
  Creates password change record with hashed password and token used to
  confirm password change
  """
  @spec create(non_neg_integer, map) :: {:ok, %PasswordChange{}} | {:error, Ecto.Changeset.t()}
  def create(specialist_id, password) do
    %PasswordChange{specialist_id: specialist_id}
    |> create_changeset(%{password: password})
    |> Repo.insert()
    |> case do
      {:ok, password_change} -> {:ok, password_change}
      {:error, changeset} -> handle_creation_error(changeset, specialist_id, password)
    end
  end

  defp handle_creation_error(changeset, specialist_id, password) do
    if Enum.any?(
         changeset.errors,
         &match?({:confirmation_token, {"has already been taken", _}}, &1)
       ) do
      create(specialist_id, password)
    else
      {:error, changeset}
    end
  end

  @doc """
  Fetches password change by confirmation token
  """
  @spec fetch_by_confirmation_token(String.t()) :: {:ok, %PasswordChange{}} | {:error, :not_found}
  def fetch_by_confirmation_token(confirmation_token) do
    PasswordChange
    |> where([pc], pc.confirmation_token == ^confirmation_token)
    |> where([pc], pc.expire_at > ^Timex.now())
    |> Repo.fetch_one()
  end
end
