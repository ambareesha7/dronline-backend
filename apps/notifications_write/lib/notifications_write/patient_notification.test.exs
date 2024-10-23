defmodule NotificationsWrite.PatientNotificationTest do
  use Postgres.DataCase, async: true

  alias NotificationsWrite.PatientNotification

  describe "notify_about_record_change/2" do
    test "creates a notification" do
      record_id = 1
      patient_id = 10
      specialist_id = 100

      :ok =
        PatientNotification.notify_about_record_change(
          record_id,
          patient_id,
          specialist_id,
          medical_summary_id: 1000
        )

      notifications = Repo.all(PatientNotification)

      assert length(notifications) == 1
    end
  end

  describe "mark_notification_as_read/2" do
    test "marks given notification as read" do
      record_id = 1
      patient_id = 10
      specialist_id = 100

      :ok =
        PatientNotification.notify_about_record_change(
          record_id,
          patient_id,
          specialist_id,
          medical_summary_id: 1000
        )

      notification = Repo.one(PatientNotification)
      refute notification.read

      :ok = PatientNotification.mark_notification_as_read(patient_id, notification.id)

      notification = Repo.one(PatientNotification)
      assert notification.read
    end

    test "succeeds when notification is already marked as read" do
      record_id = 1
      patient_id = 10
      specialist_id = 100

      :ok =
        PatientNotification.notify_about_record_change(
          record_id,
          patient_id,
          specialist_id,
          medical_summary_id: 1000
        )

      notification = Repo.one(PatientNotification)

      :ok = PatientNotification.mark_notification_as_read(patient_id, notification.id)

      assert :ok = PatientNotification.mark_notification_as_read(patient_id, notification.id)
    end

    test "raises error when patient_id and notification id doesn't match" do
      record_id = 1
      patient_id = 10
      other_patient_id = 20
      specialist_id = 100

      :ok =
        PatientNotification.notify_about_record_change(
          record_id,
          patient_id,
          specialist_id,
          medical_summary_id: 1000
        )

      notification = Repo.one(PatientNotification)

      assert_raise RuntimeError, fn ->
        PatientNotification.mark_notification_as_read(other_patient_id, notification.id)
      end
    end
  end

  describe "mark_all_notifications_as_read/1" do
    test "marks all patient's notifications as read" do
      record_1_id = 1
      record_2_id = 2
      patient_id = 10
      specialist_id = 100

      PatientNotification.notify_about_record_change(
        record_1_id,
        patient_id,
        specialist_id,
        medical_summary_id: 1000
      )

      PatientNotification.notify_about_record_change(
        record_2_id,
        patient_id,
        specialist_id,
        medical_summary_id: 1000
      )

      notifications = Repo.all(PatientNotification)
      refute Enum.any?(notifications, & &1.read)

      :ok = PatientNotification.mark_all_notifications_as_read(patient_id)

      notifications = Repo.all(PatientNotification)
      assert Enum.all?(notifications, & &1.read)
    end

    test "doesn't mark other patients' notifications" do
      record_id = 1
      patient_1_id = 10
      patient_2_id = 20
      specialist_id = 100

      PatientNotification.notify_about_record_change(
        record_id,
        patient_1_id,
        specialist_id,
        medical_summary_id: 1000
      )

      notification = Repo.one(PatientNotification)
      refute notification.read

      :ok = PatientNotification.mark_all_notifications_as_read(patient_2_id)

      notification = Repo.one(PatientNotification)
      refute notification.read
    end
  end
end
