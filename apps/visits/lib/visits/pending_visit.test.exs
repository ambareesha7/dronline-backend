defmodule Visits.PendingVisitTest do
  use Postgres.DataCase, async: true

  alias Visits.PendingVisit
  @seconds_in_minute 60

  describe "get_upcoming_for_reminder/1" do
    test "get only upcoming visits with less than given seconds to start" do
      now = DateTime.utc_now() |> DateTime.to_unix()
      seconds_to_visit = 10 * @seconds_in_minute

      {:ok, _pending_visit} =
        create_pending_visit(%{
          chosen_medical_category_id: 1,
          patient_id: 1,
          record_id: 1,
          specialist_id: 1,
          start_time: now + 9 * @seconds_in_minute,
          visit_type: :ONLINE
        })

      {:ok, _pending_visit} =
        create_pending_visit(%{
          chosen_medical_category_id: 1,
          patient_id: 1,
          record_id: 1,
          specialist_id: 1,
          start_time: now + 11 * @seconds_in_minute,
          visit_type: :ONLINE
        })

      {:ok, upcoming_pending_visit} =
        create_pending_visit(%{
          chosen_medical_category_id: 1,
          patient_id: 1,
          record_id: 1,
          specialist_id: 1,
          start_time: now + 10 * @seconds_in_minute,
          visit_type: :ONLINE
        })

      assert [fetched_visit] = PendingVisit.get_upcoming_for_reminder(seconds_to_visit)
      assert fetched_visit.id == upcoming_pending_visit.id
    end
  end

  describe "get_pending_visits_for_specialist/2" do
    test "returns all visits" do
      now = DateTime.utc_now() |> DateTime.to_unix()
      specialist_id = "1"

      {:ok, _pending_visit} =
        create_pending_visit(%{
          chosen_medical_category_id: 1,
          patient_id: 1,
          record_id: 1,
          specialist_id: specialist_id,
          start_time: now + 9 * @seconds_in_minute,
          visit_type: :ONLINE
        })

      {:ok, _pending_visit} =
        create_pending_visit(%{
          chosen_medical_category_id: 1,
          patient_id: 1,
          record_id: 1,
          specialist_id: specialist_id,
          start_time: now + 11 * @seconds_in_minute,
          visit_type: :ONLINE
        })

      assert [_, _] = PendingVisit.get_pending_visits_for_specialist(specialist_id)
    end

    test "returns upcoming visits, when `limit` is given" do
      now = DateTime.utc_now() |> DateTime.to_unix()
      specialist_id = "1"

      {:ok, first_visit} =
        create_pending_visit(%{
          chosen_medical_category_id: 1,
          patient_id: 1,
          record_id: 1,
          specialist_id: specialist_id,
          start_time: now + 9 * @seconds_in_minute,
          visit_type: :ONLINE
        })

      {:ok, _second_visit} =
        create_pending_visit(%{
          chosen_medical_category_id: 1,
          patient_id: 1,
          record_id: 1,
          specialist_id: specialist_id,
          start_time: now + 11 * @seconds_in_minute,
          visit_type: :ONLINE
        })

      assert [^first_visit] =
               PendingVisit.get_pending_visits_for_specialist(specialist_id, %{limit: 1})
    end

    test "returns visits with given type" do
      now = DateTime.utc_now() |> DateTime.to_unix()
      specialist_id = "1"

      {:ok, _online_visit} =
        create_pending_visit(%{
          chosen_medical_category_id: 1,
          patient_id: 1,
          record_id: 1,
          specialist_id: specialist_id,
          start_time: now + 9 * @seconds_in_minute,
          visit_type: :ONLINE
        })

      {:ok, in_office_visit} =
        create_pending_visit(%{
          chosen_medical_category_id: 1,
          patient_id: 1,
          record_id: 1,
          specialist_id: specialist_id,
          start_time: now + 11 * @seconds_in_minute,
          visit_type: :IN_OFFICE
        })

      assert [^in_office_visit] =
               PendingVisit.get_pending_visits_for_specialist(specialist_id, %{
                 visit_types: [:IN_OFFICE]
               })
    end

    test "returns today's visits" do
      now = DateTime.utc_now() |> DateTime.to_unix()
      specialist_id = "1"

      {:ok, _yesterday_visit} =
        create_pending_visit(%{
          chosen_medical_category_id: 1,
          patient_id: 1,
          record_id: 1,
          specialist_id: specialist_id,
          start_time:
            DateTime.utc_now()
            |> Timex.shift(days: -1)
            |> DateTime.to_unix()
            |> Kernel.*(@seconds_in_minute),
          visit_type: :ONLINE
        })

      {:ok, today_visit} =
        create_pending_visit(%{
          chosen_medical_category_id: 1,
          patient_id: 1,
          record_id: 1,
          specialist_id: specialist_id,
          start_time: now + 11 * @seconds_in_minute,
          visit_type: :IN_OFFICE
        })

      {:ok, _tommorow_visit} =
        create_pending_visit(%{
          chosen_medical_category_id: 1,
          patient_id: 1,
          record_id: 1,
          specialist_id: specialist_id,
          start_time:
            DateTime.utc_now()
            |> Timex.shift(days: 1)
            |> DateTime.to_unix()
            |> Kernel.*(@seconds_in_minute),
          visit_type: :ONLINE
        })

      assert [^today_visit] =
               PendingVisit.get_pending_visits_for_specialist(specialist_id, %{
                 today: true
               })
    end
  end

  defp create_pending_visit(params) do
    {:ok, _pending_visit} = PendingVisit.create(params)
  end
end
