defmodule Web.Api.NotificationsView do
  def render_notification(%NotificationsRead.PatientNotification{} = notification) do
    %Proto.Notifications.PatientNotification{
      id: notification.id,
      created_at: notification.inserted_at |> Timex.to_unix(),
      read: notification.read,
      type: parse_notification_type(notification)
    }
  end

  defp parse_notification_type(%{medical_summary: %{} = medical_summary}) do
    medical_summary_submitted_notification =
      %Proto.Notifications.MedicalSummarySubmittedNotification{
        specialist_id: medical_summary.specialist_id,
        medical_summary: %Proto.Notifications.MedicalSummarySubmittedNotification.MedicalSummary{
          id: medical_summary.id,
          record_id: medical_summary.timeline_id
        }
      }

    {:medical_summary_submitted_notification, medical_summary_submitted_notification}
  end

  defp parse_notification_type(%{tests_bundle: %{} = tests_bundle}) do
    tests_ordered_notification = %Proto.Notifications.TestsOrderedNotification{
      specialist_id: tests_bundle.specialist_id,
      tests_bundle: %Proto.Notifications.TestsOrderedNotification.TestsBundle{
        id: tests_bundle.id,
        record_id: tests_bundle.timeline_id
      }
    }

    {:tests_ordered_notification, tests_ordered_notification}
  end

  defp parse_notification_type(%{medications_bundle: %{} = medications_bundle}) do
    medications_assigned_notification = %Proto.Notifications.MedicationsAssignedNotification{
      specialist_id: medications_bundle.specialist_id,
      medications_bundle: %Proto.Notifications.MedicationsAssignedNotification.MedicationsBundle{
        id: medications_bundle.id,
        record_id: medications_bundle.timeline_id
      }
    }

    {:medications_assigned_notification, medications_assigned_notification}
  end
end
