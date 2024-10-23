defmodule NotificationsWrite.SpecialistNotification do
  use Postgres.Schema
  use Postgres.Service

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "specialist_notifications" do
    field :for_specialist_id, :integer
    field :read, :boolean

    field :timeline_item_comment_id, :binary_id

    timestamps(type: :utc_datetime_usec, updated_at: false)
  end

  @spec notify_about_timeline_item_comment(String.t(), [pos_integer]) :: :ok
  def notify_about_timeline_item_comment(timeline_item_comment_id, specialist_ids) do
    content = Enum.map(specialist_ids, &insertion_content(&1, timeline_item_comment_id))

    _ = Repo.insert_all(__MODULE__, content)
    _ = send_push_notifications(specialist_ids)

    :ok
  end

  defp insertion_content(specialist_id, timeline_item_comment_id) do
    %{
      for_specialist_id: specialist_id,
      timeline_item_comment_id: timeline_item_comment_id,
      inserted_at: DateTime.utc_now()
    }
  end

  defp send_push_notifications(specialist_ids) do
    PushNotifications.Message.send(%PushNotifications.Message.NewNotification{
      send_to_specialist_ids: specialist_ids
    })
  end

  @spec mark_notification_as_read(pos_integer, String.t()) :: :ok
  def mark_notification_as_read(specialist_id, notification_id) do
    __MODULE__
    |> where(for_specialist_id: ^specialist_id)
    |> where(id: ^notification_id)
    |> Repo.update_all(set: [read: true])
    |> case do
      {1, _} ->
        :ok

      _ ->
        raise "#{inspect(__MODULE__)}.mark_notification_as_read/2 failure"
    end
  end

  @spec mark_all_notifications_as_read(pos_integer) :: :ok
  def mark_all_notifications_as_read(specialist_id) do
    _ =
      __MODULE__
      |> where(for_specialist_id: ^specialist_id)
      |> Repo.update_all(set: [read: true])

    :ok
  end
end
