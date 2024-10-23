defmodule Membership.Specialists.Subscription do
  use Postgres.Service

  alias Membership.Specialists.Specialist
  alias Membership.Subscription

  @type parsed_date :: %{timestamp: pos_integer | {:error, any}}

  @spec fetch(pos_integer) :: {:ok, map, parsed_date | nil, map | nil}
  def fetch(specialist_id) do
    trial_ends_at = Repo.get_by(Specialist, id: specialist_id).trial_ends_at
    now = NaiveDateTime.utc_now()

    is_trial_active =
      case NaiveDateTime.compare(now, trial_ends_at) do
        :lt -> true
        _ -> false
      end

    {:ok, active_package, expires_at, is_active_package_cancelled} =
      fetch_active_package_info(specialist_id, is_trial_active)

    {:ok, next_package} = fetch_next_package(specialist_id, is_active_package_cancelled)

    {:ok, active_package, parse_date(expires_at), next_package}
  end

  @spec fetch_by_order_id(pos_integer, pos_integer) ::
          {:ok, %Subscription{}} | {:error, :not_found}
  def fetch_by_order_id(specialist_id, order_id) do
    Subscription
    |> where(order_id: ^order_id)
    |> where(specialist_id: ^specialist_id)
    |> Repo.fetch_one()
  end

  @spec fetch_active(pos_integer) :: {:ok, %Subscription{}} | {:error, :not_found}
  def fetch_active(specialist_id) do
    Subscription
    |> where(specialist_id: ^specialist_id)
    |> where(active: true)
    |> Repo.fetch_one()
  end

  @spec fetch_accepted(pos_integer) :: {:ok, %Subscription{}} | {:error, :not_found}
  def fetch_accepted(specialist_id) do
    Subscription
    |> where(specialist_id: ^specialist_id)
    |> where([s], not s.active and s.status == "ACCEPTED")
    |> Repo.fetch_one()
  end

  @spec fetch_pending(pos_integer) :: {:ok, %Subscription{}} | {:error, :not_found}
  def fetch_pending(specialist_id) do
    Subscription
    |> where(specialist_id: ^specialist_id)
    |> where([s], s.status == "PENDING")
    |> Repo.fetch_one()
  end

  @spec fetch_active_package_info(pos_integer, boolean) :: {:ok, map, %Date{} | nil, boolean}
  defp fetch_active_package_info(specialist_id, false = _is_trial_active) do
    with {:ok, subscription} <- fetch_active(specialist_id) do
      {:ok, package} = Membership.Packages.fetch_one(subscription.type)

      {:ok, package, subscription.next_payment_date, subscription.status == "CANCELLED"}
    else
      {:error, :not_found} ->
        {:ok, package} = Membership.Packages.fetch_one("BASIC")

        {:ok, package, nil, false}
    end
  end

  defp fetch_active_package_info(_specialist_id, true = _is_trial_active) do
    {:ok, package} = Membership.Packages.fetch_one("PLATINUM")
    {:ok, package, nil, false}
  end

  @spec fetch_next_package(pos_integer, boolean) :: {:ok, map | nil}
  defp fetch_next_package(specialist_id, is_active_package_cancelled) do
    case fetch_accepted(specialist_id) do
      {:ok, %{type: package_type}} ->
        Membership.Packages.fetch_one(package_type)

      {:error, :not_found} ->
        if is_active_package_cancelled do
          Membership.Packages.fetch_one("BASIC")
        else
          {:ok, nil}
        end
    end
  end

  defp parse_date(nil), do: nil
  defp parse_date(%Date{} = date), do: %{timestamp: Timex.to_unix(date)}
end
