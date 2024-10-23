defmodule NotificationsRead do
  # For a Specialist
  defdelegate fetch_notifications_for_specialist(specialist_id, params),
    to: NotificationsRead.SpecialistNotification,
    as: :fetch_for_specialist

  defdelegate get_unread_notifications_count_for_specialist(specialist_id),
    to: NotificationsRead.SpecialistNotification,
    as: :get_unread_count_for_specialist

  # For a Patient
  defdelegate fetch_notifications_for_patient(patient_id, params),
    to: NotificationsRead.PatientNotification,
    as: :fetch_for_patient

  defdelegate get_unread_notifications_count_for_patient(patient_id),
    to: NotificationsRead.PatientNotification,
    as: :get_unread_count_for_patient
end
