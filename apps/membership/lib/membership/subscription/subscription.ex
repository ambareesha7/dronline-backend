defmodule Membership.Subscription do
  use Postgres.Schema
  use Postgres.Service

  alias __MODULE__

  @moduledoc """
  Field status:
  PENDING subscription can be ACCEPTED or REJECTED after verifying transaction
  ACCEPTED subscription can be CANCELLED by external specialist
  ACCEPTED or CANCELLED subscription can be ENDED
  """

  schema "subscriptions" do
    field :accepted_at, :naive_datetime_usec
    field :active, :boolean, default: false
    field :agreement_id, :string
    field :cancelled_at, :naive_datetime_usec
    field :checked_at, :naive_datetime_usec
    field :day, :integer
    field :declined_at, :naive_datetime_usec
    field :ended_at, :naive_datetime_usec
    field :last_payment_at, :naive_datetime_usec
    field :next_payment_count, :integer, default: 1
    field :next_payment_date, :date
    field :order_id, :string
    field :ref, :string
    field :specialist_id, :integer
    field :status, :string, default: "PENDING"
    field :type, :string
    field :webview_url, :string
  end

  @create_fields [:order_id, :next_payment_date, :ref, :specialist_id, :type, :webview_url]
  defp create_changeset(%Subscription{} = subscription, params) do
    subscription
    |> cast(params, @create_fields)
    |> validate_required(@create_fields)
    |> validate_inclusion(:type, ["SILVER", "GOLD", "PLATINUM"])
    |> unique_constraint(:_specialist_id,
      name: "unique_pending_subscription_index",
      message: "another subscription is pending"
    )
  end

  @update_fields [
    :accepted_at,
    :active,
    :agreement_id,
    :cancelled_at,
    :checked_at,
    :day,
    :declined_at,
    :ended_at,
    :last_payment_at,
    :next_payment_count,
    :next_payment_date,
    :ref,
    :status
  ]
  defp update_changeset(%Subscription{} = subscription, params) do
    subscription
    |> cast(params, @update_fields)
    |> validate_inclusion(:status, ["ACCEPTED", "DECLINED", "REJECTED", "CANCELLED", "ENDED"])
  end

  @spec create(map) :: {:ok, %Subscription{}} | {:error, Ecto.Changeset.t()}
  def create(params) do
    %Subscription{}
    |> create_changeset(params)
    |> Repo.insert()
  end

  @spec update(pos_integer, map) :: {:ok, %Subscription{}} | {:error, Ecto.Changeset.t()}
  def update(subscription_id, params) do
    {:ok, subscription} = fetch_by_id(subscription_id)

    subscription
    |> update_changeset(params)
    |> Repo.update()
    |> case do
      {:ok, _subscription} -> fetch_by_id(subscription_id)
      error -> error
    end
  end

  @spec fetch_by_id(pos_integer) :: {:ok, %Subscription{}} | {:error, :not_found}
  def fetch_by_id(id) do
    Subscription
    |> where(id: ^id)
    |> Repo.fetch_one()
  end

  @verification_interval 5 * 60
  @spec get_pending_to_verify() :: {:ok, [%Subscription{}]}
  def get_pending_to_verify do
    verification_interval_timestamp = Timex.now() |> Timex.shift(seconds: -@verification_interval)

    {_, subscriptions} =
      Membership.Subscription
      |> where([s], s.status == "PENDING")
      |> where([s], s.checked_at < ^verification_interval_timestamp)
      |> select([s], s)
      |> Repo.update_all([set: [checked_at: Timex.now()]], log: false)

    {:ok, subscriptions}
  end

  @spec abandon_existing_pending(pos_integer) :: {:ok, [%Subscription{}]}
  def abandon_existing_pending(specialist_id) do
    {_, subscriptions} =
      Membership.Subscription
      |> where([s], s.status == "PENDING" and s.specialist_id == ^specialist_id)
      |> select([s], s)
      |> Repo.update_all([set: [status: "ABANDONED"]], log: false)

    {:ok, subscriptions}
  end

  @due_verification_interval 60 * 60
  @spec fetch_due_subscriptions() :: {:ok, [%Subscription{}]}
  def fetch_due_subscriptions do
    today = Timex.today()

    verification_interval_timestamp =
      Timex.now() |> Timex.shift(seconds: -@due_verification_interval)

    {_, subscriptions} =
      Membership.Subscription
      |> where([s], s.active and s.next_payment_date <= ^today)
      |> where([s], s.checked_at < ^verification_interval_timestamp)
      |> select([s], s)
      |> Repo.update_all([set: [checked_at: Timex.now()]], log: false)

    {:ok, subscriptions}
  end
end
