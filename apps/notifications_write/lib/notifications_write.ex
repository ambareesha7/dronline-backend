defmodule NotificationsWrite do
  # For a Specialist
  defdelegate mark_all_specialist_notifications_as_read(specialist_id),
    to: NotificationsWrite.SpecialistNotification,
    as: :mark_all_notifications_as_read

  defdelegate mark_specialist_notification_as_read(specialist_id, notification_id),
    to: NotificationsWrite.SpecialistNotification,
    as: :mark_notification_as_read

  defdelegate notify_specialists_about_timeline_item_comment(
                timeline_item_comment_id,
                specialists_ids
              ),
              to: NotificationsWrite.SpecialistNotification,
              as: :notify_about_timeline_item_comment

  # For a Patient
  defdelegate mark_all_patient_notifications_as_read(patient_id),
    to: NotificationsWrite.PatientNotification,
    as: :mark_all_notifications_as_read

  defdelegate mark_patient_notification_as_read(patient_id, notification_id),
    to: NotificationsWrite.PatientNotification,
    as: :mark_notification_as_read

  defdelegate notify_patient_about_record_change(
                record_id,
                patient_id,
                specialist_id,
                opts
              ),
              to: NotificationsWrite.PatientNotification,
              as: :notify_about_record_change
end
