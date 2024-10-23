defmodule MembershipMock.Subscription do
  use Postgres.Schema
  use Postgres.Service

  @primary_key {:specialist_id, :integer, autogenerate: false}
  schema "mocked_subscriptions" do
    field :type, :string

    field :webview_url, :string, virtual: true

    timestamps()
  end

  # @spec cancel(pos_integer) :: :ok | {:error, :not_found}
  @spec cancel(pos_integer) :: :ok
  def cancel(specialist_id) do
    _ =
      __MODULE__
      |> where(specialist_id: ^specialist_id)
      |> Repo.delete_all()

    :ok
  end

  # @spec create(non_neg_integer, String.t()) ::
  #         {:ok, String.t() | nil} | {:error, :invalid_action} | {:error, :wrong_package_type}
  @spec create(non_neg_integer, String.t()) :: {:ok, String.t()}
  def create(_specialist_id, type) do
    {:ok, webview_url(type)}
  end

  # @spec fetch(pos_integer) :: {:ok, map, %{timestamp: pos_integer} | nil, map | nil}
  @spec fetch(pos_integer) :: {:ok, map, %{timestamp: pos_integer}, nil}
  def fetch(specialist_id) do
    %{package_type: package_type, trial_ends_at: trial_ends_at} =
      "specialists"
      |> where(id: ^specialist_id)
      |> select([s], %{package_type: s.package_type, trial_ends_at: s.trial_ends_at})
      |> Repo.one()

    subscription = Repo.get(__MODULE__, specialist_id) || %{type: package_type}

    {:ok, package} = Membership.Packages.fetch_one(subscription.type)
    {:ok, package, %{timestamp: Timex.to_unix(trial_ends_at)}, nil}
  end

  # @spec fetch_pending(pos_integer) :: {:ok, %__MODULE__{}} | {:error, :not_found}
  @spec fetch_pending(pos_integer) :: {:error, :not_found}
  def fetch_pending(_specialist_id) do
    {:error, :not_found}
  end

  # @spec verify(non_neg_integer, non_neg_integer) :: {:ok, atom} | {:error, any()}
  @spec verify(non_neg_integer, String.t()) :: {:ok, atom}
  def verify(specialist_id, order_id) when order_id in ["BASIC", "SILVER", "GOLD", "PLATINUM"] do
    type = order_id

    _ =
      %__MODULE__{specialist_id: specialist_id, type: type}
      |> Repo.insert(
        on_conflict: {:replace, [:type, :updated_at]},
        conflict_target: :specialist_id
      )

    for topic <- ["doctor", "external"] do
      Membership.ChannelBroadcast.push(%{
        topic: topic,
        event: "active_package_update",
        payload: %{
          proto: %Proto.Membership.ActivePackageUpdate{
            type: type
          },
          external_id: specialist_id
        }
      })
    end

    {:ok, :PAID}
  end

  defp webview_url(type) do
    panel_url = :web |> Application.get_env(:specialist_panel_url) |> URI.parse()
    order_id = type

    redirect_url = panel_url |> URI.merge("/membership/verify/#{order_id}") |> to_string()

    panel_url |> URI.merge("/demo-payments?redirect_url=#{redirect_url}") |> to_string()
  end
end
