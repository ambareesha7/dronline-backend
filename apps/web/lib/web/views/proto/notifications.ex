defmodule Web.View.Notifications do
  def render_notification(%NotificationsRead.SpecialistNotification{} = notification) do
    %Proto.Notifications.Notification{
      id: notification.id,
      created_at: notification.inserted_at |> Timex.to_unix(),
      read: notification.read,
      type: parse_notification_type(notification)
    }
  end

  defp parse_notification_type(%{timeline_item_comment: %{} = timeline_item_comment}) do
    timeline_item_comment_notification = %Proto.Notifications.TimelineItemCommentNotification{
      patient_id: timeline_item_comment.patient_id,
      record_id: timeline_item_comment.record_id,
      timeline_item_id: timeline_item_comment.timeline_item_id,
      timeline_item_comment: Web.View.EMR.render_timeline_item_comment(timeline_item_comment),
      commented_on: timeline_item_comment.commented_on
    }

    {:timeline_item_comment_notification, timeline_item_comment_notification}
  end
end
