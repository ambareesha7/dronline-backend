defmodule NotificationsRead.SpecialistNotificationTest do
  use Postgres.DataCase, async: true

  alias NotificationsRead.SpecialistNotification

  defp prepare_notifications(comment_id, specialist_ids) do
    NotificationsWrite.notify_specialists_about_timeline_item_comment(comment_id, specialist_ids)
  end

  defp prepare_comment(specialist_id) do
    cmd = %EMR.PatientRecords.Timeline.Commands.CreateItemComment{
      body: "BODY",
      commented_by_specialist_id: specialist_id,
      commented_on: "HPI",
      patient_id: 1,
      record_id: 1,
      timeline_item_id: UUID.uuid4()
    }

    {:ok, comment, _updated_comments_counter} =
      EMR.PatientRecords.Timeline.Item.Comment.create(cmd)

    comment
  end

  describe "fetch_for_specialist/2" do
    test "returns correct entries when next token is missing" do
      specialist_id = 1
      other_specialist1_id = 2
      other_specialist2_id = 3

      :ok = prepare_notifications(prepare_comment(other_specialist1_id).id, [specialist_id])
      :ok = prepare_notifications(prepare_comment(other_specialist2_id).id, [specialist_id])

      [notification1, notification2] =
        SpecialistNotification |> order_by(asc: :inserted_at) |> Repo.all()

      params = %{"limit" => "1"}

      {:ok, [returned_notification], [returned_specialist_id], next_token} =
        SpecialistNotification.fetch_for_specialist(specialist_id, params)

      assert returned_notification.id == notification2.id
      assert returned_specialist_id == other_specialist2_id
      assert next_token == DateTime.to_iso8601(notification1.inserted_at)
    end

    test "returns correct entries when next token is present" do
      specialist_id = 1
      other_specialist1_id = 2
      other_specialist2_id = 3

      :ok = prepare_notifications(prepare_comment(other_specialist1_id).id, [specialist_id])
      :ok = prepare_notifications(prepare_comment(other_specialist2_id).id, [specialist_id])

      [notification1, _notification2] =
        SpecialistNotification |> order_by(asc: :inserted_at) |> Repo.all()

      params = %{"limit" => "1", "next_token" => DateTime.to_iso8601(notification1.inserted_at)}

      {:ok, [returned_notification], [returned_specialist_id], next_token} =
        SpecialistNotification.fetch_for_specialist(specialist_id, params)

      assert returned_notification.id == notification1.id
      assert returned_specialist_id == other_specialist1_id
      assert next_token == ""
    end
  end

  describe "get_unread_count_for_specialist/1" do
    test "counts only unread notifications" do
      specialist_id = 1

      :ok = prepare_notifications(UUID.uuid4(), [specialist_id])
      :ok = prepare_notifications(UUID.uuid4(), [specialist_id])

      [notification1, _notification2] = Repo.all(SpecialistNotification)

      assert SpecialistNotification.get_unread_count_for_specialist(specialist_id) == 2

      NotificationsWrite.mark_specialist_notification_as_read(specialist_id, notification1.id)

      assert SpecialistNotification.get_unread_count_for_specialist(specialist_id) == 1
    end

    test "doesn't count notifications of another specialist" do
      specialist1_id = 1
      specialist2_id = 2

      :ok = prepare_notifications(UUID.uuid4(), [specialist1_id, specialist2_id])

      assert SpecialistNotification.get_unread_count_for_specialist(specialist1_id) == 1
    end
  end
end
