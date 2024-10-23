defmodule NotificationsRead.SpecialistNotification do
  use Postgres.Schema
  use Postgres.Service

  @primary_key {:id, :binary_id, autogenerate: false}
  schema "specialist_notifications" do
    field :for_specialist_id, :integer
    field :read, :boolean

    belongs_to :timeline_item_comment, EMR.PatientRecords.Timeline.Item.Comment, type: :binary_id

    timestamps(type: :utc_datetime_usec, updated_at: false)
  end

  @spec fetch_for_specialist(pos_integer, map) ::
          {:ok, [%__MODULE__{}], [pos_integer], String.t()}
  def fetch_for_specialist(specialist_id, params) do
    {:ok, result, next_token} =
      __MODULE__
      |> where(for_specialist_id: ^specialist_id)
      |> join(:left, [n], tic in assoc(n, :timeline_item_comment))
      |> preload([n, tic], timeline_item_comment: tic)
      |> where(^Postgres.Option.next_token(params, :inserted_at, :desc))
      |> order_by(desc: :inserted_at)
      |> Repo.fetch_paginated(params, :inserted_at)

    {:ok, result, parse_specialist_ids(result), parse_next_token(next_token)}
  end

  defp parse_next_token(nil), do: ""
  defp parse_next_token(nt), do: DateTime.to_iso8601(nt)

  defp parse_specialist_ids(notifications) do
    notifications
    |> Enum.map(& &1.timeline_item_comment.commented_by_specialist_id)
    |> Enum.uniq()
  end

  @spec get_unread_count_for_specialist(pos_integer) :: non_neg_integer
  def get_unread_count_for_specialist(specialist_id) do
    __MODULE__
    |> where(for_specialist_id: ^specialist_id)
    |> where(read: false)
    |> select(count())
    |> Repo.one()
  end
end
