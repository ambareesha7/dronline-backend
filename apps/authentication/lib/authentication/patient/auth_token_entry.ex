defmodule Authentication.Patient.AuthTokenEntry do
  use Postgres.Schema
  use Postgres.Service

  @primary_key {:patient_id, :integer, autogenerate: false}
  schema "patient_auth_token_entries" do
    field :auth_token, :string

    timestamps()
  end

  @required_fields [:auth_token, :patient_id]

  @spec create(pos_integer) :: {:ok, %__MODULE__{}}
  def create(patient_id) do
    %__MODULE__{patient_id: patient_id}
    |> cast(%{}, [])
    |> generate_token(:auth_token, 30)
    |> validate_required(@required_fields)
    |> unique_constraint(:auth_token)
    |> Repo.insert()
    |> case do
      {:ok, %__MODULE__{} = auth_token_entry} ->
        {:ok, auth_token_entry}

      {:error, %Ecto.Changeset{} = changeset} ->
        handle_create_error(changeset, patient_id)
    end
  end

  defp generate_token(changeset, field, size) do
    changeset |> put_change(field, Authentication.Random.url_safe(size))
  end

  defp handle_create_error(changeset, patient_id) do
    %{errors: errors} = changeset

    if Enum.any?(errors, &match?({:auth_token, {"has already been taken", _}}, &1)) do
      create(patient_id)
    else
      _ = Sentry.Context.set_extra_context(%{changeset: changeset})
      raise "#{inspect(__MODULE__)}.handle_create_error/2 failure"
    end
  end

  @spec fetch_by_patient_id(pos_integer) :: {:ok, %__MODULE__{}} | {:error, :not_found}
  def fetch_by_patient_id(patient_id) do
    Repo.fetch_by(__MODULE__, patient_id: patient_id)
  end

  @spec fetch_patient_id_by_auth_token(String.t()) :: {:ok, pos_integer} | {:error, :not_found}
  def fetch_patient_id_by_auth_token(token) do
    __MODULE__
    |> where(auth_token: ^token)
    |> select([ate], ate.patient_id)
    |> Repo.fetch_one()
  end

  @spec get_by_patient_ids([pos_integer]) :: [%__MODULE__{}]
  def get_by_patient_ids(patient_ids) do
    __MODULE__
    |> where([ate], ate.patient_id in ^patient_ids)
    |> Repo.all()
  end
end
