defmodule NotificationsWrite.SpecialistNotificationTest do
  use Postgres.DataCase, async: true

  alias NotificationsWrite.SpecialistNotification

  describe "notify_about_timeline_item_comment/2" do
    test "creates separate notification entry for every provided specialist" do
      comment_id = UUID.uuid4()
      specialist1_id = 1
      specialist2_id = 2

      specialist_ids = [specialist1_id, specialist2_id]
      :ok = SpecialistNotification.notify_about_timeline_item_comment(comment_id, specialist_ids)

      notifications = Repo.all(SpecialistNotification)

      assert length(notifications) == 2

      fetched_specialist_ids = Enum.map(notifications, & &1.for_specialist_id)
      assert specialist1_id in fetched_specialist_ids
      assert specialist2_id in fetched_specialist_ids
    end

    test "marks new notification as unread" do
      comment_id = UUID.uuid4()
      specialist_id = 1

      :ok = SpecialistNotification.notify_about_timeline_item_comment(comment_id, [specialist_id])

      notification = Repo.one(SpecialistNotification)

      refute notification.read
    end
  end

  describe "mark_notification_as_read/2" do
    test "marks given notification as read" do
      comment_id = UUID.uuid4()
      specialist_id = 1
      :ok = SpecialistNotification.notify_about_timeline_item_comment(comment_id, [specialist_id])

      notification = Repo.one(SpecialistNotification)
      refute notification.read

      :ok = SpecialistNotification.mark_notification_as_read(specialist_id, notification.id)

      notification = Repo.one(SpecialistNotification)
      assert notification.read
    end

    test "succeeds when notification is already marked as read" do
      comment_id = UUID.uuid4()
      specialist_id = 1
      :ok = SpecialistNotification.notify_about_timeline_item_comment(comment_id, [specialist_id])

      notification = Repo.one(SpecialistNotification)

      :ok = SpecialistNotification.mark_notification_as_read(specialist_id, notification.id)

      assert :ok =
               SpecialistNotification.mark_notification_as_read(specialist_id, notification.id)
    end

    test "raises error when specialist_id and notification id doesn't match" do
      comment_id = UUID.uuid4()
      specialist_id = 1
      other_specialist_id = 2
      :ok = SpecialistNotification.notify_about_timeline_item_comment(comment_id, [specialist_id])

      notification = Repo.one(SpecialistNotification)

      assert_raise RuntimeError, fn ->
        SpecialistNotification.mark_notification_as_read(other_specialist_id, notification.id)
      end
    end
  end

  describe "mark_all_notifications_as_read/1" do
    test "marks all specialist notifications as read" do
      comment1_id = UUID.uuid4()
      comment2_id = UUID.uuid4()
      specialist_id = 1

      SpecialistNotification.notify_about_timeline_item_comment(comment1_id, [specialist_id])
      SpecialistNotification.notify_about_timeline_item_comment(comment2_id, [specialist_id])

      notifications = Repo.all(SpecialistNotification)
      refute Enum.any?(notifications, & &1.read)

      :ok = SpecialistNotification.mark_all_notifications_as_read(specialist_id)

      notifications = Repo.all(SpecialistNotification)
      assert Enum.all?(notifications, & &1.read)
    end

    test "doesn't mark other specialists notifications" do
      comment_id = UUID.uuid4()
      specialist1_id = 1
      specialist2_id = 2

      SpecialistNotification.notify_about_timeline_item_comment(comment_id, [specialist1_id])

      notification = Repo.one(SpecialistNotification)
      refute notification.read

      :ok = SpecialistNotification.mark_all_notifications_as_read(specialist2_id)

      notification = Repo.one(SpecialistNotification)
      refute notification.read
    end
  end
end
