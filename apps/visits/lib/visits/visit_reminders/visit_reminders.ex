defmodule Visits.VisitReminders do
  use Postgres.Service

  import Mockery.Macro

  alias Ecto.Multi
  alias Visits.StartingVisitReminder
  alias Visits.UpcomingVisitReminder

  @upcoming_reminder_seconds 10 * 60
  @starting_reminder_seconds 60

  defmacrop notification do
    quote do: mockable(PushNotifications.Message)
  end

  def remind_about_visits(opts \\ []) do
    Multi.new()
    |> lock_notifications_table(opts)
    |> fetch_upcoming_visits(opts)
    |> fetch_starting_visits(opts)
    |> send_notifications()
    |> Repo.transaction(opts)

    :ok
  end

  defp lock_notifications_table(multi, opts) do
    Multi.run(multi, :lock_notification_tables, fn _repo, _changes ->
      {:ok, _} =
        Repo.query("LOCK TABLE sent_visit_reminders_v2 IN ACCESS EXCLUSIVE MODE", [], opts)

      {:ok, _} =
        Repo.query("LOCK TABLE sent_visit_starting_reminders IN ACCESS EXCLUSIVE MODE", [], opts)
    end)
  end

  defp fetch_upcoming_visits(multi, opts) do
    Multi.run(multi, :fetch_upcoming_visits, fn _repo, _changes ->
      visits = Visits.PendingVisit.get_upcoming_for_reminder(@upcoming_reminder_seconds, opts)
      {:ok, visits}
    end)
  end

  defp fetch_starting_visits(multi, opts) do
    Multi.run(multi, :fetch_starting_visits, fn _repo, _changes ->
      visits = Visits.PendingVisit.get_starting_for_reminder(@starting_reminder_seconds, opts)
      {:ok, visits}
    end)
  end

  defp send_notifications(multi) do
    Multi.run(multi, :send_notifications, fn _repo, changes ->
      %{
        fetch_upcoming_visits: upcoming_visits,
        fetch_starting_visits: starting_visits
      } = changes

      Enum.each(upcoming_visits, fn visit ->
        send_notification(visit, :upcoming)
        mark_as_sent(visit, :upcoming)
      end)

      Enum.each(starting_visits, fn visit ->
        send_notification(visit, :starting)
        mark_as_sent(visit, :starting)
      end)

      {:ok, :notifications_sent}
    end)
  end

  defp send_notification(visit, time_till_visit) when time_till_visit in [:upcoming, :starting] do
    notification().send(%PushNotifications.Message.VisitReminderForPatient{
      record_id: visit.record_id,
      send_to_patient_id: PatientProfilesManagement.who_should_be_notified(visit.patient_id),
      time_till_visit: time_till_visit
    })

    notification().send(%PushNotifications.Message.VisitReminderForSpecialist{
      patient_id: visit.patient_id,
      record_id: visit.record_id,
      specialist_id: visit.specialist_id,
      time_till_visit: time_till_visit
    })
  end

  defp mark_as_sent(visit, :upcoming) do
    %UpcomingVisitReminder{
      visit_id: visit.id,
      visit_start_time: visit.start_time
    }
    |> Repo.insert()
  end

  defp mark_as_sent(visit, :starting) do
    %StartingVisitReminder{
      visit_id: visit.id,
      visit_start_time: visit.start_time
    }
    |> Repo.insert()
  end
end
