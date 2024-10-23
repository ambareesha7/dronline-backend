defmodule SpecialistProfile.Prices do
  use Postgres.Schema
  use Postgres.Service

  alias Ecto.Multi
  alias SpecialistProfile.Prices.MedicalCategory
  alias SpecialistProfile.Status

  @available_currencies ["INR", "AED", "USD"]

  schema "specialists_medical_categories" do
    field :price_minutes_15, :integer, default: 0
    field :price_minutes_30, :integer, default: 0
    field :price_minutes_45, :integer, default: 0
    field :price_minutes_60, :integer, default: 0
    field :price_second_opinion, :integer, default: 0
    field :price_in_office, :integer, default: 0
    field :prices_enabled, :boolean
    field :currency, :string
    field :currency_in_office, :string

    field :specialist_id, :integer
    belongs_to :medical_category, MedicalCategory
  end

  @required [
    :price_minutes_15,
    :price_minutes_30,
    :price_minutes_45,
    :price_minutes_60,
    :price_second_opinion,
    :price_in_office,
    :medical_category_id
  ]

  @optional [:currency, :currency_in_office]

  @fields @required ++ @optional

  @spec update(pos_integer, map) :: {:ok, %__MODULE__{}} | {:error, Ecto.Changeset.t()}
  def update(specialist_id, params) when is_integer(specialist_id) do
    Multi.new()
    |> Multi.run(:update_prices, &do_update_prices(&1, &2, specialist_id, params))
    |> Multi.run(:handle_onboarding_status, &handle_onboarding_status(&1, &2, specialist_id))
    |> Postgres.Repo.transaction()
    |> case do
      {:ok, changes} ->
        {:ok, Repo.preload(changes.update_prices, :medical_category)}

      {:error, _failed_operation, changeset, _changes_so_far} ->
        {:error, changeset}
    end
  end

  def do_update_prices(_repo, _multi, specialist_id, params) when is_integer(specialist_id) do
    specialist_id
    |> get_or_create_prices_struct(params)
    |> cast(params, @fields)
    |> validate_required(@required)
    |> put_change(:prices_enabled, true)
    |> validate_required_price(params)
    |> validate_15_minutes_currency(params)
    |> validate_in_office_currency(params)
    |> Repo.insert_or_update()
  end

  @spec fetch_by_specialist_and_category_id(pos_integer, pos_integer) ::
          {:ok, %__MODULE__{}} | {:error, :not_found}
  def fetch_by_specialist_and_category_id(specialist_id, medical_category_id)
      when is_integer(specialist_id) do
    __MODULE__
    |> where(
      [p],
      p.specialist_id == ^specialist_id and p.medical_category_id == ^medical_category_id
    )
    |> Repo.fetch_one()
  end

  @spec fetch_by_specialist_id(pos_integer) :: %__MODULE__{} | nil
  def fetch_by_specialist_id(specialist_id) when is_integer(specialist_id) do
    preload_medical_categories()
    |> where([p], p.specialist_id == ^specialist_id)
    |> Repo.all()
  end

  @spec fetch_by_specialist_id([pos_integer]) :: [%__MODULE__{}]
  def fetch_by_specialists_id(specialists_id) when is_list(specialists_id) do
    preload_medical_categories()
    |> where([p], p.specialist_id in ^specialists_id)
    |> Repo.all()
  end

  defp preload_medical_categories do
    __MODULE__
    |> join(:inner, [p], mc in assoc(p, :medical_category),
      as: :medical_category,
      on: p.medical_category_id == mc.id
    )
    |> preload([medical_category: mc], medical_category: mc)
  end

  defp get_or_create_prices_struct(specialist_id, params) do
    Repo.get_by(
      __MODULE__,
      specialist_id: specialist_id,
      medical_category_id: params[:medical_category_id]
    ) ||
      %__MODULE__{
        specialist_id: specialist_id,
        medical_category_id: params[:medical_category_id]
      }
  end

  defp handle_onboarding_status(_repo, _multi, specialist_id) do
    Status.handle_onboarding_status(specialist_id)

    {:ok, :handled}
  end

  defp validate_required_price(changeset, %{
         price_minutes_15: price_minutes_15,
         price_in_office: price_in_office
       })
       when price_minutes_15 <= 0 and price_in_office <= 0 do
    add_error(changeset, :price_minutes_15, "or price_in_office has to be greater than 0")
  end

  defp validate_required_price(changeset, _params), do: changeset

  defp validate_15_minutes_currency(changeset, %{
         price_minutes_15: price_minutes_15,
         currency: currency
       })
       when price_minutes_15 > 0 and currency not in @available_currencies do
    add_error(changeset, :currency, "has to be one of #{Enum.join(@available_currencies, ", ")}")
  end

  defp validate_15_minutes_currency(changeset, _params), do: changeset

  defp validate_in_office_currency(changeset, %{
         price_in_office: price_in_office,
         currency_in_office: currency_in_office
       })
       when price_in_office > 0 and currency_in_office not in @available_currencies do
    add_error(
      changeset,
      :currency_in_office,
      "has to be one of #{Enum.join(@available_currencies, ", ")}"
    )
  end

  defp validate_in_office_currency(changeset, _params), do: changeset
end
