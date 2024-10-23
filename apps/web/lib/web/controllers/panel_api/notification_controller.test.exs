defmodule Web.PanelApi.NotificationControllerTest do
  use Web.ConnCase, async: true

  alias Proto.Notifications.GetNotificationsResponse
  alias Proto.Notifications.NotificationsCounterResponse

  defp prepare_notification(current_gp) do
    patient = PatientProfile.Factory.insert(:patient)
    record = EMR.Factory.insert(:automatic_record, patient_id: patient.id)

    cmd = %EMR.PatientRecords.Timeline.Commands.CreateCallItem{
      patient_id: patient.id,
      record_id: record.id,
      specialist_id: current_gp.id
    }

    {:ok, timeline_item} = EMR.create_call_timeline_item(cmd)

    other_specialist = Authentication.Factory.insert(:specialist)
    _ = SpecialistProfile.Factory.insert(:basic_info, specialist_id: other_specialist.id)

    cmd = %EMR.PatientRecords.Timeline.Commands.CreateItemComment{
      body: "TEST",
      commented_by_specialist_id: other_specialist.id,
      commented_on: "HPI",
      patient_id: patient.id,
      record_id: record.id,
      timeline_item_id: timeline_item.id
    }

    {:ok, comment, _updated_comments_counter} = EMR.create_timeline_item_comment(cmd)

    {other_specialist, comment}
  end

  describe "GET index" do
    setup [:authenticate_gp]

    test "returns notifications data", %{conn: conn, current_gp: current_gp} do
      {other_specialist, comment} = prepare_notification(current_gp)

      conn = get(conn, panel_notification_path(conn, :index))

      assert %GetNotificationsResponse{
               notifications: [
                 %Proto.Notifications.Notification{
                   type: {
                     :timeline_item_comment_notification,
                     %Proto.Notifications.TimelineItemCommentNotification{
                       timeline_item_comment: returned_timeline_item_comment
                     }
                   }
                 }
               ],
               specialists: [%Proto.Generics.Specialist{} = returned_specialist],
               unread_notifications_counter: returned_unread_notifications_counter,
               next_token: ""
             } = proto_response(conn, 200, GetNotificationsResponse)

      assert returned_timeline_item_comment.id == comment.id
      assert returned_timeline_item_comment.commented_by_specialist_id == other_specialist.id

      assert returned_specialist.id == other_specialist.id

      assert returned_unread_notifications_counter == 1
    end
  end

  describe "GET unread_count" do
    setup [:authenticate_gp]

    test "returns count", %{conn: conn, current_gp: current_gp} do
      _ = prepare_notification(current_gp)

      conn = get(conn, panel_notification_path(conn, :unread_count))

      assert %NotificationsCounterResponse{
               unread_notifications_counter: 1
             } = proto_response(conn, 200, NotificationsCounterResponse)
    end
  end

  describe "POST mark_as_read" do
    setup [:authenticate_gp]

    test "marks notification as read and returns new counter", %{
      conn: conn,
      current_gp: current_gp
    } do
      _ = prepare_notification(current_gp)

      {:ok, [notification], _specialist_ids, _next_token} =
        NotificationsRead.fetch_notifications_for_specialist(current_gp.id, %{})

      assert NotificationsRead.get_unread_notifications_count_for_specialist(current_gp.id) == 1
      conn = post(conn, panel_notification_path(conn, :mark_as_read, notification))

      assert %NotificationsCounterResponse{
               unread_notifications_counter: returned_unread_notifications_counter
             } = proto_response(conn, 200, NotificationsCounterResponse)

      assert returned_unread_notifications_counter == 0
    end
  end

  describe "POST mark_all_as_read" do
    setup [:authenticate_gp]

    test "marks notification as read and returns new counter", %{
      conn: conn,
      current_gp: current_gp
    } do
      _ = prepare_notification(current_gp)

      assert NotificationsRead.get_unread_notifications_count_for_specialist(current_gp.id) == 1
      conn = post(conn, panel_notification_path(conn, :mark_all_as_read))

      assert response(conn, 200)

      assert NotificationsRead.get_unread_notifications_count_for_specialist(current_gp.id) == 0
    end
  end
end
