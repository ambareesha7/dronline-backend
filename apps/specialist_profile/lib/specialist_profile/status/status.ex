defmodule SpecialistProfile.Status do
  use Postgres.Schema
  use Postgres.Service

  alias SpecialistProfile.BasicInfo
  alias SpecialistProfile.Location
  alias SpecialistProfile.MedicalCredentials
  alias SpecialistProfile.Specialist

  alias __MODULE__

  schema "specialists" do
    field :approval_status, :string
    field :onboarding_completed_at, :naive_datetime_usec
    field :package_type, :string
    field :trial_ends_at, :naive_datetime
    field :has_seen_pricing_tables, :boolean

    timestamps()
  end

  @doc """
  Fetches specialist profile status flags by specialist_id
  """
  @spec fetch_by_specialist_id(pos_integer) :: {:ok, map}
  def fetch_by_specialist_id(specialist_id) do
    Status
    |> Repo.fetch(specialist_id)
    |> case do
      {:ok, status} -> {:ok, parse_result(status)}
      error -> error
    end
  end

  defp parse_result(status) do
    %{
      package_type: status.package_type |> String.to_existing_atom(),
      onboarding_completed: status.onboarding_completed_at |> parse_onboarding_completed(),
      approval_status: status.approval_status |> String.to_existing_atom(),
      trial_ends_at: status.trial_ends_at,
      has_seen_pricing_tables: status.has_seen_pricing_tables
    }
  end

  defp parse_onboarding_completed(nil), do: false
  defp parse_onboarding_completed(_status), do: true

  @doc """
  Set onboarding_completed_at for the specialist
  identified by given specialist_id to current timestamp
  """
  @spec handle_onboarding_status(pos_integer) :: :ok
  def handle_onboarding_status(specialist_id) do
    {:ok, specialist} = Specialist.fetch_by_id(specialist_id)

    if onboarding_completed?(specialist) do
      Status
      |> where([s], s.id == ^specialist.id and is_nil(s.onboarding_completed_at))
      |> Repo.update_all(
        set: [onboarding_completed_at: DateTime.utc_now(), updated_at: DateTime.utc_now()]
      )
    end

    :ok
  end

  def mark_pricing_tables_seen(specialist_id) do
    Status
    |> where([s], s.id == ^specialist_id)
    |> Repo.update_all(set: [has_seen_pricing_tables: true])

    :ok
  end

  defp onboarding_completed?(%{type: "EXTERNAL"} = specialist) do
    has_all_present?(specialist.id, [
      BasicInfo,
      Location,
      "specialists_medical_categories",
      MedicalCredentials
    ])
  end

  defp onboarding_completed?(%{type: type} = specialist) when type in ["GP", "NURSE"] do
    has_all_present?(specialist.id, [BasicInfo])
  end

  defp has_all_present?(specialist_id, modules) do
    Status
    |> where(id: ^specialist_id)
    |> inner_join_required_modules(modules, specialist_id)
    |> fetch_or_get_zero()
    |> case do
      {:ok, count} when count > 0 -> true
      _ -> false
    end
  end

  defp inner_join_required_modules(nil, _modules, _specialist_id), do: nil
  defp inner_join_required_modules(query, [], _specialist_id), do: query

  defp inner_join_required_modules(
         query,
         ["specialists_medical_categories" | modules],
         specialist_id
       ) do
    SpecialistProfile.Prices
    |> where(specialist_id: ^specialist_id)
    |> where([p], p.price_minutes_15 == 0)
    |> Repo.all()
    |> Enum.empty?()
    |> if do
      inner_join_required_modules(query, modules, specialist_id)
    else
      inner_join_required_modules(nil, modules, specialist_id)
    end
  end

  defp inner_join_required_modules(query, [module | modules], specialist_id) do
    query
    |> join(:inner, [s], m in ^module, on: s.id == m.specialist_id)
    |> inner_join_required_modules(modules, specialist_id)
  end

  defp fetch_or_get_zero(nil), do: {:ok, 0}

  defp fetch_or_get_zero(query) do
    query
    |> select(count())
    |> Repo.fetch_one()
  end
end
