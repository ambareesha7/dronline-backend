defmodule NotificationsRead.PatientNotificationTest do
  use Postgres.DataCase, async: true

  alias NotificationsRead.PatientNotification

  defp prepare_notification(patient_id, specialist_id) do
    record_id = 1

    bundle =
      EMR.Factory.insert(:medications_bundle,
        patient_id: patient_id,
        timeline_id: record_id,
        specialist_id: specialist_id,
        medications: [
          %{
            name: "Medication 1",
            direction: "Direction 1",
            quantity: "Quantity 1",
            refills: 1,
            price_aed: 2000
          }
        ]
      )

    NotificationsWrite.notify_patient_about_record_change(
      record_id,
      patient_id,
      specialist_id,
      medications_bundle_id: bundle.id
    )
  end

  describe "fetch_for_patient/2" do
    test "returns correct entries when next token is missing" do
      patient_id = 10
      specialist_id = 100

      :ok = prepare_notification(patient_id, specialist_id)
      :ok = prepare_notification(patient_id, specialist_id)

      [notification_1, notification_2] =
        PatientNotification |> order_by(asc: :inserted_at) |> Repo.all()

      params = %{"limit" => "1"}

      {:ok, [returned_notification], [returned_specialist_id], next_token} =
        PatientNotification.fetch_for_patient(patient_id, params)

      assert returned_notification.id == notification_2.id
      assert returned_specialist_id == specialist_id
      assert next_token == DateTime.to_iso8601(notification_1.inserted_at)
    end

    test "returns correct entries when next token is present" do
      patient_id = 10
      specialist_id = 100

      :ok = prepare_notification(patient_id, specialist_id)
      :ok = prepare_notification(patient_id, specialist_id)

      [notification_1, _notification_2] =
        PatientNotification |> order_by(asc: :inserted_at) |> Repo.all()

      params = %{"limit" => "1", "next_token" => DateTime.to_iso8601(notification_1.inserted_at)}

      {:ok, [returned_notification], [returned_specialist_id], next_token} =
        PatientNotification.fetch_for_patient(patient_id, params)

      assert returned_notification.id == notification_1.id
      assert returned_specialist_id == specialist_id
      assert next_token == ""
    end
  end

  describe "get_unread_count_for_patient/1" do
    test "counts only unread notifications" do
      patient_id = 10
      specialist_id = 100

      :ok = prepare_notification(patient_id, specialist_id)
      :ok = prepare_notification(patient_id, specialist_id)

      [notification_1, _notification_2] = Repo.all(PatientNotification)

      assert PatientNotification.get_unread_count_for_patient(patient_id) == 2

      NotificationsWrite.mark_patient_notification_as_read(patient_id, notification_1.id)

      assert PatientNotification.get_unread_count_for_patient(patient_id) == 1
    end

    test "doesn't count notifications of another patient" do
      patient_1_id = 10
      patient_2_id = 20
      specialist_id = 100

      :ok = prepare_notification(patient_1_id, specialist_id)
      :ok = prepare_notification(patient_2_id, specialist_id)

      assert PatientNotification.get_unread_count_for_patient(patient_1_id) == 1
    end
  end
end
