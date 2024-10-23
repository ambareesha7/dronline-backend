defmodule SpecialistProfile.MedicalCredentials do
  use Postgres.Schema
  use Postgres.Service

  alias __MODULE__
  alias Ecto.Multi
  alias SpecialistProfile.Status

  schema "specialist_medical_credentials" do
    field :dea_number_url, :string
    field :dea_number_expiry_date, :date
    field :board_certification_url, :string
    field :board_certification_expiry_date, :date
    field :current_state_license_number_url, :string
    field :current_state_license_number_expiry_date, :date

    field :specialist_id, :integer

    timestamps()
  end

  @fields [
    :dea_number_url,
    :dea_number_expiry_date,
    :board_certification_url,
    :board_certification_expiry_date,
    :current_state_license_number_url,
    :current_state_license_number_expiry_date
  ]
  def changeset(struct, params) do
    struct
    |> cast(params, @fields)
  end

  @doc """
  Fetches medical credentials of specialist for given specialist id
  """
  @spec fetch_by_specialist_id(pos_integer) :: {:ok, %MedicalCredentials{}}
  def fetch_by_specialist_id(specialist_id) do
    MedicalCredentials
    |> where(specialist_id: ^specialist_id)
    |> Repo.fetch_one()
    |> case do
      {:ok, medical_credentials} ->
        {:ok, medical_credentials}

      {:error, :not_found} ->
        {:ok, %MedicalCredentials{specialist_id: specialist_id}}
    end
  end

  @doc """
  Fetches medical credentials of specialist for given specialist ids
  """
  @spec fetch_by_specialist_ids([pos_integer]) :: {:ok, [%MedicalCredentials{}]}
  def fetch_by_specialist_ids(specialist_ids) do
    MedicalCredentials
    |> where([mc], mc.specialist_id in ^specialist_ids)
    |> Repo.fetch_all()
  end

  @doc """
  Update medical credentials of specialist identified by given specialist id with passed params
  """
  @spec update(map, pos_integer) :: {:ok, map} | {:error, Ecto.Changeset.t()}
  def update(params, specialist_id) do
    Multi.new()
    |> Multi.run(:update_credentials, &update_credentials(&1, &2, specialist_id, params))
    |> Multi.run(:handle_onboarding_status, &handle_onboarding_status(&1, &2, specialist_id))
    |> Postgres.Repo.transaction()
    |> case do
      {:ok, _changes} ->
        {:ok, %{}} = MedicalCredentials.Fetch.call(specialist_id)

      {:error, _failed_operation, changeset, _changes_so_far} ->
        {:error, changeset}
    end
  end

  defp update_credentials(_repo, _multi, specialist_id, params) do
    {:ok, medical_credentials} = fetch_by_specialist_id(specialist_id)

    medical_credentials
    |> MedicalCredentials.changeset(params)
    |> Repo.insert_or_update()
  end

  defp handle_onboarding_status(_repo, _multi, specialist_id) do
    Status.handle_onboarding_status(specialist_id)

    {:ok, :handled}
  end
end
