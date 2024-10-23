defmodule SpecialistProfile.Specialist do
  use Postgres.Schema
  use Postgres.Service

  alias __MODULE__
  alias Ecto.Multi
  alias SpecialistProfile.Insurances
  alias SpecialistProfile.MedicalCategories.MedicalCategory
  alias SpecialistProfile.Status

  schema "specialists" do
    field :approval_status, :string
    field :package_type, :string

    field :type, :string

    many_to_many :medical_categories, SpecialistProfile.MedicalCategories.MedicalCategory,
      join_through: "specialists_medical_categories",
      on_replace: :delete

    many_to_many :insurance_providers, SpecialistProfile.Insurances.Provider,
      join_through: "specialists_insurance_providers",
      on_replace: :delete

    timestamps()
  end

  def categories_changeset(struct, categories) do
    struct
    |> change()
    |> put_assoc(:medical_categories, categories)
  end

  def insurance_providers_changeset(struct, providers) do
    struct
    |> change()
    |> put_assoc(:insurance_providers, providers)
  end

  @spec fetch_by_id(pos_integer) :: {:ok, %Specialist{}} | {:error, :not_found}
  def fetch_by_id(id) do
    Repo.fetch(Specialist, id)
  end

  @spec fetch_all_by_category(pos_integer) :: [{pos_integer}]
  def fetch_all_by_category(category_id) do
    Specialist
    |> join(:left, [s], mc in assoc(s, :medical_categories))
    |> where([s, mc], mc.id == ^category_id and s.approval_status == "VERIFIED")
    |> select([s], {s.id})
    |> Repo.all()
  end

  @doc """
  Updates medical categories for doctor
  """
  @spec update_categories([pos_integer], pos_integer) ::
          {:ok, [%MedicalCategory{}]} | {:error, Ecto.Changeset.t()}
  def update_categories(categories_ids, specialist_id) do
    {:ok, categories} = MedicalCategory.fetch_by_ids(categories_ids)

    Multi.new()
    |> Multi.run(:update_categories, &do_update_categories(&1, &2, specialist_id, categories))
    |> Multi.run(:handle_onboarding_status, &handle_onboarding_status(&1, &2, specialist_id))
    |> Postgres.Repo.transaction()
    |> case do
      {:ok, changes} ->
        {:ok, changes.update_categories.medical_categories}

      {:error, _failed_operation, changeset, _changes_so_far} ->
        {:error, changeset}
    end
  end

  defp do_update_categories(_repo, _multi, specialist_id, categories) do
    specialist_id
    |> fetch_by_id_for_categories_update()
    |> case do
      {:ok, specialist} ->
        specialist
        |> categories_changeset(categories)
        |> Repo.update()

      {:error, :not_found} ->
        {:error, :forbidden}
    end
  end

  defp fetch_by_id_for_categories_update(id) do
    Specialist
    |> where([s], s.id == ^id)
    |> join(:left, [s], mc in assoc(s, :medical_categories))
    |> preload([_s, mc], medical_categories: mc)
    |> Repo.fetch_one()
  end

  @doc """
  Updates medical categories for doctor
  """
  @spec update_insurance_providers(pos_integer, [pos_integer]) ::
          {:ok, %Insurances.Provider{}} | {:error, Ecto.Changeset.t()}
  def update_insurance_providers(specialist_id, providers_ids) do
    {:ok, providers} = Insurances.Provider.fetch_by_ids(providers_ids)

    Multi.new()
    |> Multi.run(
      :update_insurance_providers,
      &do_update_insurance_providers(&1, &2, specialist_id, providers)
    )
    |> Multi.run(:handle_onboarding_status, &handle_onboarding_status(&1, &2, specialist_id))
    |> Postgres.Repo.transaction()
    |> case do
      {:ok, changes} ->
        {:ok, changes.update_insurance_providers.insurance_providers}

      {:error, _failed_operation, changeset, _changes_so_far} ->
        {:error, changeset}
    end
  end

  def fetch_by_ids_with_insurance_providers(ids) do
    Specialist
    |> where([s], s.id in ^ids)
    |> join(:left, [s], ip in assoc(s, :insurance_providers))
    |> preload([_s, ip], insurance_providers: ip)
    |> Repo.all()
  end

  defp do_update_insurance_providers(_repo, _multi, specialist_id, insurance_providers) do
    specialist_id
    |> fetch_by_id_for_insurance_providers_update()
    |> case do
      {:ok, specialist} ->
        specialist
        |> insurance_providers_changeset(insurance_providers)
        |> Repo.update()

      {:error, :not_found} ->
        {:error, :forbidden}
    end
  end

  defp fetch_by_id_for_insurance_providers_update(id) do
    Specialist
    |> where([s], s.id == ^id)
    |> join(:left, [s], ip in assoc(s, :insurance_providers))
    |> preload([_s, ip], insurance_providers: ip)
    |> Repo.fetch_one()
  end

  defp handle_onboarding_status(_repo, _multi, specialist_id) do
    Status.handle_onboarding_status(specialist_id)

    {:ok, :handled}
  end
end
