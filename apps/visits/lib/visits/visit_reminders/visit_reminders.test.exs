defmodule Visits.VisitRemindersTest do
  use Postgres.DataCase, async: true

  import Mockery.Assertions

  @seconds_in_minute 60

  defp create_pending_visit(params) do
    {:ok, _pending_visit} = Visits.PendingVisit.create(params)
  end

  describe "remind_about_upcoming_visits/0" do
    # TODO please fix it :)
    @tag :skip
    test "sends notification about upcoming visit only once" do
      now = DateTime.utc_now() |> DateTime.to_unix()

      {:ok, upcoming_pending_visit} =
        create_pending_visit(%{
          chosen_medical_category_id: 1,
          patient_id: 1,
          record_id: 1,
          specialist_id: 1,
          start_time: now + 10 * @seconds_in_minute,
          visit_type: :ONLINE
        })

      {:ok, _upcoming_pending_visit_not_in_range} =
        create_pending_visit(%{
          chosen_medical_category_id: 1,
          patient_id: 1,
          record_id: 1,
          specialist_id: 1,
          start_time: now + 9 * @seconds_in_minute,
          visit_type: :ONLINE
        })

      {:ok, _upcoming_pending_visit_not_in_range} =
        create_pending_visit(%{
          chosen_medical_category_id: 1,
          patient_id: 1,
          record_id: 1,
          specialist_id: 1,
          start_time: now + 11 * @seconds_in_minute,
          visit_type: :ONLINE
        })

      # call remind_about_visits twice to check if notification won't be sent twice
      :ok = Visits.VisitReminders.remind_about_visits()
      :ok = Visits.VisitReminders.remind_about_visits()

      expected_upcoming_patient_notification = %PushNotifications.Message.VisitReminderForPatient{
        record_id: upcoming_pending_visit.record_id,
        send_to_patient_id: upcoming_pending_visit.patient_id,
        time_till_visit: :upcoming
      }

      expected_upcoming_specialist_notification =
        %PushNotifications.Message.VisitReminderForSpecialist{
          patient_id: upcoming_pending_visit.patient_id,
          record_id: upcoming_pending_visit.record_id,
          specialist_id: upcoming_pending_visit.specialist_id,
          time_till_visit: :upcoming
        }

      assert_called(
        PushNotifications.Message,
        :send,
        [
          ^expected_upcoming_patient_notification
        ],
        1
      )

      assert_called(
        PushNotifications.Message,
        :send,
        [
          ^expected_upcoming_specialist_notification
        ],
        1
      )
    end

    test "sends notification about starting prepared visit only once" do
      now = DateTime.utc_now() |> DateTime.to_unix()

      {:ok, starting_pending_visit} =
        create_pending_visit(%{
          chosen_medical_category_id: 1,
          patient_id: 1,
          record_id: 1,
          specialist_id: 1,
          start_time: now,
          visit_type: :ONLINE
        })

      {:ok, _starting_pending_visit_not_in_range} =
        create_pending_visit(%{
          chosen_medical_category_id: 1,
          patient_id: 1,
          record_id: 1,
          specialist_id: 1,
          start_time: now + 60,
          visit_type: :ONLINE
        })

      expected_starting_patient_notification = %PushNotifications.Message.VisitReminderForPatient{
        record_id: starting_pending_visit.record_id,
        send_to_patient_id: starting_pending_visit.patient_id,
        time_till_visit: :starting
      }

      expected_starting_specialist_notification =
        %PushNotifications.Message.VisitReminderForSpecialist{
          patient_id: starting_pending_visit.patient_id,
          record_id: starting_pending_visit.record_id,
          specialist_id: starting_pending_visit.specialist_id,
          time_till_visit: :starting
        }

      # call remind_about_visits twice to check if notification won't be sent twice
      :ok = Visits.VisitReminders.remind_about_visits()
      :ok = Visits.VisitReminders.remind_about_visits()

      assert_called(
        PushNotifications.Message,
        :send,
        [
          ^expected_starting_patient_notification
        ],
        1
      )

      assert_called(
        PushNotifications.Message,
        :send,
        [
          ^expected_starting_specialist_notification
        ],
        1
      )
    end

    test "doesn't send notifications about visits which are not prepared" do
      now = DateTime.utc_now() |> DateTime.to_unix()

      {:ok, _pending_visit} =
        Visits.PendingVisit.create(%{
          chosen_medical_category_id: 1,
          patient_id: 1,
          record_id: 1,
          specialist_id: 1,
          start_time: now + 5 * @seconds_in_minute,
          visit_type: :ONLINE
        })

      assert :ok = Visits.VisitReminders.remind_about_visits()

      refute_called(PushNotifications.Message, :send)
    end
  end
end
