defmodule Web.Api.NotificationControllerTest do
  use Web.ConnCase, async: true

  alias Proto.Notifications.GetPatientNotificationsResponse
  alias Proto.Notifications.NotificationsCounterResponse

  defp prepare_notification(patient) do
    record = EMR.Factory.insert(:automatic_record, patient_id: patient.id)
    specialist = Authentication.Factory.insert(:specialist)
    _ = SpecialistProfile.Factory.insert(:basic_info, specialist_id: specialist.id)

    bundle =
      EMR.Factory.insert(:medications_bundle,
        patient_id: patient.id,
        timeline_id: record.id,
        specialist_id: specialist.id,
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
      record.id,
      patient.id,
      specialist.id,
      medications_bundle_id: bundle.id
    )

    {specialist, record}
  end

  describe "GET index" do
    setup [:authenticate_patient]

    test "returns notifications data", %{conn: conn, current_patient: current_patient} do
      {specialist, record} = prepare_notification(current_patient)

      conn = get(conn, notification_path(conn, :index))

      assert %GetPatientNotificationsResponse{
               notifications: [
                 %Proto.Notifications.PatientNotification{
                   type: {
                     :medications_assigned_notification,
                     %Proto.Notifications.MedicationsAssignedNotification{
                       specialist_id: returned_specialist_id,
                       medications_bundle:
                         %Proto.Notifications.MedicationsAssignedNotification.MedicationsBundle{
                           id: _,
                           record_id: returned_record_id
                         }
                     }
                   }
                 }
               ],
               specialists: [%Proto.Generics.Specialist{id: returned_specialist_id}],
               next_token: ""
             } = proto_response(conn, 200, GetPatientNotificationsResponse)

      assert returned_record_id == record.id
      assert returned_specialist_id == specialist.id
    end
  end

  describe "GET unread_count" do
    setup [:authenticate_patient]

    test "returns notifications data", %{conn: conn, current_patient: current_patient} do
      _ = prepare_notification(current_patient)

      conn = get(conn, notification_path(conn, :unread_count))

      assert %NotificationsCounterResponse{
               unread_notifications_counter: 1
             } = proto_response(conn, 200, NotificationsCounterResponse)
    end
  end

  describe "POST mark_as_read" do
    setup [:authenticate_patient]

    test "marks notification as read and returns new counter", %{
      conn: conn,
      current_patient: current_patient
    } do
      _ = prepare_notification(current_patient)
      _ = prepare_notification(current_patient)

      {:ok, [notification_1, _notification_2], _specialist_ids, _next_token} =
        NotificationsRead.fetch_notifications_for_patient(current_patient.id, %{})

      assert NotificationsRead.get_unread_notifications_count_for_patient(current_patient.id) == 2

      conn = post(conn, notification_path(conn, :mark_as_read, notification_1))

      assert %NotificationsCounterResponse{
               unread_notifications_counter: returned_unread_notifications_counter
             } = proto_response(conn, 200, NotificationsCounterResponse)

      assert returned_unread_notifications_counter == 1
    end
  end

  describe "POST mark_all_as_read" do
    setup [:authenticate_patient]

    test "marks notification as read and returns new counter", %{
      conn: conn,
      current_patient: current_patient
    } do
      _ = prepare_notification(current_patient)

      assert NotificationsRead.get_unread_notifications_count_for_patient(current_patient.id) == 1
      conn = post(conn, notification_path(conn, :mark_all_as_read))

      assert response(conn, 200)

      assert NotificationsRead.get_unread_notifications_count_for_patient(current_patient.id) == 0
    end
  end
end
