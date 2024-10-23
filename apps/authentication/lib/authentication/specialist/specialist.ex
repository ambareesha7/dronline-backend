defmodule Authentication.Specialist do
  use Postgres.Schema
  use Postgres.Service

  alias __MODULE__
  alias Authentication.Specialist.ChangesetHelpers

  @hours_to_recovery_token_expiration 12

  schema "specialists" do
    field :type, :string
    field :package_type, :string, default: "PLATINUM"

    field :email, :string

    field :auth_token, :string
    field :password, :string, virtual: true
    field :password_hash, :string

    field :verification_token, :string
    field :verified, :boolean

    field :onboarding_completed_at, :naive_datetime_usec
    field :approval_status, :string, default: "WAITING"

    field :password_recovery_token, :string
    field :password_recovery_token_expire_at, :naive_datetime_usec

    timestamps()
  end

  @fields [:email, :password, :type]
  @required [:auth_token, :email, :password, :type, :verification_token]
  defp registration_changeset(%Specialist{} = specialist, params) do
    specialist
    |> cast(params, @fields)
    |> ChangesetHelpers.generate_token(:auth_token, 30)
    |> ChangesetHelpers.generate_token(:verification_token, 20)
    |> ChangesetHelpers.handle_password()
    |> validate_required(@required)
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:auth_token)
    |> unique_constraint(:email)
    |> unique_constraint(:verification_token)
  end

  defp new_password_changeset(specialist, params) do
    specialist
    |> cast(params, [:password])
    |> ChangesetHelpers.generate_token(:auth_token, 30)
    |> ChangesetHelpers.handle_password()
    |> put_change(:password_recovery_token, nil)
    |> unique_constraint(:auth_token)
  end

  defp password_recovery_changeset(specialist) do
    specialist
    |> change()
    |> ChangesetHelpers.generate_token(:password_recovery_token, 20)
    |> put_token_expiration_datetime()
    |> unique_constraint(:password_recovery_token)
  end

  defp verification_changeset(%Specialist{} = specialist) do
    specialist |> change(%{verified: true, verification_token: nil})
  end

  defp update_password_hash_changeset(%Specialist{} = specialist, params) do
    specialist
    |> cast(params, [:password_hash])
    |> ChangesetHelpers.generate_token(:auth_token, 30)
    |> unique_constraint(:auth_token)
  end

  defp put_token_expiration_datetime(changeset) do
    expiration_datetime =
      Timex.now()
      |> Timex.shift(hours: @hours_to_recovery_token_expiration)
      |> Timex.to_naive_datetime()

    put_change(changeset, :password_recovery_token_expire_at, expiration_datetime)
  end

  @doc """
  Registers specialist
  """
  @spec register(map) ::
          {:ok, %Specialist{}}
          | {:error, Ecto.Changeset.t() | :email_taken}
  def register(params) do
    specialist =
      Repo.get_by(Specialist, email: Map.get(params, :email), verified: false) ||
        %Specialist{}

    changeset = registration_changeset(specialist, params)

    result =
      case Ecto.get_meta(specialist, :state) do
        :loaded ->
          Repo.update(changeset)

        :built ->
          Repo.insert(changeset)
      end

    case result do
      {:ok, specialist} ->
        {:ok, specialist}

      {:error, changeset} ->
        handle_registration_error(changeset, params)
    end
  end

  defp handle_registration_error(changeset, params) do
    %{errors: errors} = changeset

    cond do
      Enum.any?(errors, &match?({:email, {"has already been taken", _}}, &1)) ->
        {:error, :email_taken}

      Enum.any?(errors, &match?({:auth_token, {"has already been taken", _}}, &1)) ->
        register(params)

      Enum.any?(errors, &match?({:verification_token, {"has already been taken", _}}, &1)) ->
        register(params)

      :else ->
        {:error, changeset}
    end
  end

  @doc """
  Creates password recovery token

  In case of uniqueness error on recovery token it will loop.
  By design it should not be possible to get `{:error, changeset}` as result.
  """
  @spec create_password_recovery_token(struct) :: {:ok, struct}
  def create_password_recovery_token(specialist) do
    changeset = password_recovery_changeset(specialist)

    case Repo.update(changeset) do
      {:ok, specialist} ->
        {:ok, specialist}

      {:error, changeset} ->
        handle_password_recovery_error(changeset, specialist)
    end
  end

  defp handle_password_recovery_error(changeset, specialist) do
    if Enum.any?(
         changeset.errors,
         &match?({:password_recovery_token, {"has already been taken", _}}, &1)
       ) do
      create_password_recovery_token(specialist)
    else
      Sentry.Context.set_extra_context(%{changeset: changeset})

      raise "failure in #{inspect(__MODULE__)}.create_password_recovery_token/1"
    end
  end

  @doc """
  Sets specialist as verified.
  """
  @spec verify(%Specialist{}) :: {:ok, %Specialist{}} | {:error, Ecto.Changeset.t()}
  def verify(%Specialist{} = specialist) do
    specialist
    |> verification_changeset()
    |> Repo.update()
  end

  @doc """
  Fetches specialist by id
  """
  @spec fetch_by_id(non_neg_integer) :: {:ok, %Specialist{}} | {:error, :not_found}
  def fetch_by_id(id) do
    Repo.fetch(Specialist, id)
  end

  @spec fetch_by_ids([pos_integer]) :: {:ok, [%__MODULE__{}]}
  def fetch_by_ids(ids) do
    __MODULE__
    |> where([s], s.id in ^ids)
    |> Repo.fetch_all()
  end

  @doc """
  Fetches specialist based on auth_token

  Used for the authentication of endpoints and therefore limited to returning only id and type.
  Returns error either if token is invalid or specialist unverified.
  """
  @spec fetch_by_auth_token(String.t()) :: {:ok, %Specialist{}} | {:error, :not_found}
  def fetch_by_auth_token(token) do
    Specialist
    |> where(auth_token: ^token)
    |> where(verified: true)
    |> select([u], %{
      id: u.id,
      type: u.type,
      package_type: u.package_type,
      approval_status: u.approval_status,
      onboarding_completed_at: u.onboarding_completed_at
    })
    |> Repo.fetch_one()
  end

  @doc """
  Fetches specialist based on email

  Used to fetch specialist during login.
  """
  @spec fetch_by_email(String.t()) :: {:ok, %Specialist{}} | {:error, :not_found}
  def fetch_by_email(email) do
    Repo.fetch_by(Specialist, email: email)
  end

  @doc """
  Fetches specialist based on password_recovery_token

  Used during password recovery.
  Returns error either if token is invalid or specialist unverified.
  """
  @spec fetch_by_password_recovery_token(String.t()) ::
          {:ok, %__MODULE__{}} | {:error, :not_found}
  def fetch_by_password_recovery_token(token) do
    __MODULE__
    |> where(password_recovery_token: ^token)
    |> where(
      [s],
      s.password_recovery_token_expire_at > ^Timex.now() or
        is_nil(s.password_recovery_token_expire_at)
    )
    |> where(verified: true)
    |> Repo.fetch_one()
  end

  @doc """
  Fetches specialist based on email

  Returns error either if email is invalid or specialist unverified.
  """
  @spec fetch_by_verified_email(String.t()) :: {:ok, %Specialist{}} | {:error, :not_found}
  def fetch_by_verified_email(email) do
    Specialist
    |> where(email: ^email)
    |> where(verified: true)
    |> Repo.fetch_one()
  end

  @doc """
  Fetches specialist based on verification_token

  Used during verification.
  Returns error either if token is invalid.
  """
  @spec fetch_by_verification_token(String.t()) :: {:ok, %Specialist{}} | {:error, :not_found}
  def fetch_by_verification_token(token) do
    Specialist
    |> where(verification_token: ^token)
    |> Repo.fetch_one()
  end

  @doc """
  Sets new password and generates new auth token

  Used during password recovery.
  It also removes previous password recovery token.
  """
  @spec set_new_password(%__MODULE__{}, String.t()) ::
          {:ok, %__MODULE__{}} | {:error, Ecto.Changeset.t()}
  def set_new_password(specialist, password) do
    specialist
    |> new_password_changeset(%{password: password})
    |> Repo.update()
    |> case do
      {:ok, specialist} ->
        {:ok, specialist}

      {:error, changeset} ->
        handle_new_password_error(changeset, specialist, password)
    end
  end

  defp handle_new_password_error(changeset, specialist, password) do
    if Enum.any?(
         changeset.errors,
         &match?({:auth_token, {"has already been taken", _}}, &1)
       ) do
      set_new_password(specialist, password)
    else
      {:error, changeset}
    end
  end

  @doc """
  Updates password hash and generates new auth token

  Used during password change.
  """
  @spec update_password_hash(non_neg_integer, String.t()) ::
          {:ok, :updated} | {:error, :not_found}
  def update_password_hash(specialist_id, password_hash) do
    {:ok, specialist} = Specialist.fetch_by_id(specialist_id)

    specialist
    |> update_password_hash_changeset(%{password_hash: password_hash})
    |> Repo.update()
    |> case do
      {:ok, specialist} ->
        {:ok, specialist}

      {:error, changeset} ->
        handle_update_password_hash(changeset, specialist_id, password_hash)
    end
  end

  defp handle_update_password_hash(changeset, specialist_id, password_hash) do
    auth_token_taken? = &match?({:auth_token, {"has already been taken", _}}, &1)

    if Enum.any?(changeset.errors, auth_token_taken?) do
      update_password_hash(specialist_id, password_hash)
    else
      {:error, changeset}
    end
  end
end
