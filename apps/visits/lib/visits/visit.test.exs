defmodule Visits.VisitTest do
  use Postgres.DataCase, async: true

  alias Visits.Visit

  @seconds_in_hour 60 * 60
  @seconds_in_day 24 * @seconds_in_hour
  @seconds_in_year 356 * @seconds_in_day

  defp prepare_visit(patient_id, record_id, start_time) do
    Visits.PendingVisit.create(%{
      chosen_medical_category_id: 1,
      patient_id: patient_id,
      record_id: record_id,
      specialist_id: 1,
      start_time: start_time,
      visit_type: :ONLINE
    })
  end

  defp prepare_canceled_visit(patient_id, record_id, start_time) do
    Repo.insert(%Visits.CanceledVisit{
      id: UUID.uuid4(),
      chosen_medical_category_id: 1,
      patient_id: patient_id,
      record_id: record_id,
      specialist_id: 1,
      start_time: start_time,
      canceled_by: "doctor",
      visit_type: :ONLINE
    })
  end

  describe "fetch_for_patients/2" do
    test "allows pagination" do
      patient_id = 1
      record_id = 1

      now = DateTime.utc_now() |> DateTime.to_unix()
      {:ok, visit1} = prepare_visit(patient_id, record_id, now)
      {:ok, visit2} = prepare_visit(patient_id, record_id, now + @seconds_in_day)

      params = %{"limit" => "1"}
      assert {:ok, [visit], next_token} = Visit.fetch_for_patients([patient_id], params)
      assert visit.visit.id == visit2.id
      assert next_token == visit1.start_time

      params = %{"limit" => "1", "next_token" => next_token}
      assert {:ok, [visit], nil} = Visit.fetch_for_patients([patient_id], params)
      assert visit.visit.id == visit1.id
    end

    test "returns list sorted descending by start time" do
      patient_id = 1
      record_id = 1

      now = DateTime.utc_now() |> DateTime.to_unix()
      {:ok, visit1} = prepare_visit(patient_id, record_id, now)
      {:ok, visit2} = prepare_visit(patient_id, record_id, now + @seconds_in_day)

      params = %{"limit" => "2"}

      assert {:ok, [fetched_visit2, fetched_visit1], nil} =
               Visit.fetch_for_patients([patient_id], params)

      assert fetched_visit2.visit.id == visit2.id
      assert fetched_visit1.visit.id == visit1.id
    end

    test "when filter is set to Scheduled" do
      patient_id = 1
      record_id = 1

      now = DateTime.utc_now() |> DateTime.to_unix()

      {:ok, _done} = prepare_visit(patient_id, record_id, now - @seconds_in_year)
      {:ok, _ongoing} = prepare_visit(patient_id, record_id, now)
      {:ok, scheduled} = prepare_visit(patient_id, record_id, now + @seconds_in_year)

      params = %{"status" => "SCHEDULED"}
      {:ok, [fetched], nil} = Visit.fetch_for_patients([patient_id], params)
      assert fetched.visit.start_time == scheduled.start_time
      assert fetched.visit.specialist_id == scheduled.specialist_id
    end

    test "when filter is set to Ongoing" do
      patient_id = 1
      record_id = 1

      now = DateTime.utc_now() |> DateTime.to_unix()

      {:ok, _done} = prepare_visit(patient_id, record_id, now - @seconds_in_year)
      {:ok, ongoing} = prepare_visit(patient_id, record_id, now)
      {:ok, _scheduled} = prepare_visit(patient_id, record_id, now + @seconds_in_year)

      params = %{"status" => "ONGOING"}
      {:ok, [fetched], nil} = Visit.fetch_for_patients([patient_id], params)
      assert fetched.visit.start_time == ongoing.start_time
      assert fetched.visit.specialist_id == ongoing.specialist_id
    end

    test "when filter is set to Done" do
      patient_id = 1
      record_id = 1

      now = DateTime.utc_now() |> DateTime.to_unix()

      {:ok, done} = prepare_visit(patient_id, record_id, now - @seconds_in_year)
      {:ok, _ongoing} = prepare_visit(patient_id, record_id, now)
      {:ok, _scheduled} = prepare_visit(patient_id, record_id, now + @seconds_in_year)

      params = %{"status" => "DONE"}
      {:ok, [fetched], nil} = Visit.fetch_for_patients([patient_id], params)
      assert fetched.visit.start_time == done.start_time
      assert fetched.visit.specialist_id == done.specialist_id
    end

    test "when filter is set to Cancelled" do
      patient_id = 1
      record_id = 1

      now = DateTime.utc_now() |> DateTime.to_unix()

      {:ok, _done} = prepare_visit(patient_id, record_id, now - @seconds_in_year)
      {:ok, _ongoing} = prepare_visit(patient_id, record_id, now)
      {:ok, _scheduled} = prepare_visit(patient_id, record_id, now + @seconds_in_year)

      {:ok, canceled_visit} =
        prepare_canceled_visit(patient_id, record_id, now + @seconds_in_year)

      params = %{"status" => "CANCELED"}

      {:ok, [result_visit], nil} = Visit.fetch_for_patients([patient_id], params)

      assert result_visit.visit.id == canceled_visit.id
      assert result_visit.visit.state == "CANCELED"
    end

    test "doesn't return visit of not selected patients" do
      patient_id = 1
      record_id = 1

      now = DateTime.utc_now() |> DateTime.to_unix()
      {:ok, _visit} = prepare_visit(patient_id, record_id, now)

      params = %{"limit" => "1"}

      {:ok, [], nil} = Visit.fetch_for_patients([2], params)
    end

    test "allows to return visits of multiple selected patients" do
      first_patient_id = 1
      first_record_id = 1

      second_patient_id = 2
      second_record_id = 2

      now = DateTime.utc_now() |> DateTime.to_unix()
      {:ok, visit1} = prepare_visit(first_patient_id, first_record_id, now + 1)
      {:ok, visit2} = prepare_visit(second_patient_id, second_record_id, now + 2)

      patient_ids = [first_patient_id, second_patient_id]
      params = %{}

      {:ok, [fetched1, fetched2], nil} = Visit.fetch_for_patients(patient_ids, params)
      assert fetched1.visit.id == visit2.id
      assert fetched2.visit.id == visit1.id
    end
  end

  describe "fetch_for_record/3" do
    test "allows pagination" do
      patient_id = 1
      record_id = 1

      now = DateTime.utc_now() |> DateTime.to_unix()
      {:ok, visit1} = prepare_visit(patient_id, record_id, now)
      {:ok, visit2} = prepare_visit(patient_id, record_id, now + @seconds_in_day)

      params = %{"limit" => "1"}

      assert {:ok, [visit], next_token} =
               Visit.fetch_for_record(patient_id, record_id, params)

      assert visit.id == visit2.id
      assert next_token == visit1.start_time

      params = %{"limit" => "1", "next_token" => next_token}
      assert {:ok, [visit], nil} = Visit.fetch_for_record(patient_id, record_id, params)
      assert visit.id == visit1.id
    end

    test "when next token is missing" do
      patient_id = 1
      record_id = 1

      now = DateTime.utc_now() |> DateTime.to_unix()
      {:ok, visit} = prepare_visit(patient_id, record_id, now)

      params = %{"limit" => "1"}

      {:ok, [fetched], nil} = Visit.fetch_for_record(patient_id, record_id, params)
      assert fetched.start_time == visit.start_time
      assert fetched.specialist_id == visit.specialist_id
    end

    test "when next token is blank string" do
      patient_id = 1
      record_id = 1

      now = DateTime.utc_now() |> DateTime.to_unix()
      {:ok, visit} = prepare_visit(patient_id, record_id, now)

      params = %{"limit" => "1", "next_token" => ""}

      {:ok, [fetched], nil} = Visit.fetch_for_record(patient_id, record_id, params)
      assert fetched.start_time == visit.start_time
      assert fetched.specialist_id == visit.specialist_id
    end

    test "when next token is valid" do
      patient_id = 1
      record_id = 1

      now = DateTime.utc_now() |> DateTime.to_unix()
      {:ok, visit} = prepare_visit(patient_id, record_id, now)

      params = %{"limit" => "1", "next_token" => to_string(visit.start_time)}

      {:ok, [fetched], nil} = Visit.fetch_for_record(patient_id, record_id, params)
      assert fetched.start_time == visit.start_time
      assert fetched.specialist_id == visit.specialist_id
    end

    test "when filter is set to Scheduled" do
      patient_id = 1
      record_id = 1

      now = DateTime.utc_now() |> DateTime.to_unix()

      {:ok, _done} = prepare_visit(patient_id, record_id, now - @seconds_in_year)
      {:ok, _ongoing} = prepare_visit(patient_id, record_id, now)
      {:ok, scheduled} = prepare_visit(patient_id, record_id, now + @seconds_in_year)

      params = %{"status" => "SCHEDULED"}
      {:ok, [fetched], nil} = Visit.fetch_for_record(patient_id, record_id, params)
      assert fetched.start_time == scheduled.start_time
      assert fetched.specialist_id == scheduled.specialist_id
    end

    test "when filter is set to Ongoing" do
      patient_id = 1
      record_id = 1

      now = DateTime.utc_now() |> DateTime.to_unix()

      {:ok, _done} = prepare_visit(patient_id, record_id, now - @seconds_in_year)
      {:ok, ongoing} = prepare_visit(patient_id, record_id, now)
      {:ok, _scheduled} = prepare_visit(patient_id, record_id, now + @seconds_in_year)

      params = %{"status" => "ONGOING"}
      {:ok, [fetched], nil} = Visit.fetch_for_record(patient_id, record_id, params)
      assert fetched.start_time == ongoing.start_time
      assert fetched.specialist_id == ongoing.specialist_id
    end

    test "when filter is set to Done" do
      patient_id = 1
      record_id = 1

      now = DateTime.utc_now() |> DateTime.to_unix()

      {:ok, done} = prepare_visit(patient_id, record_id, now - @seconds_in_year)
      {:ok, _ongoing} = prepare_visit(patient_id, record_id, now)
      {:ok, _scheduled} = prepare_visit(patient_id, record_id, now + @seconds_in_year)

      params = %{"status" => "DONE"}
      {:ok, [fetched], nil} = Visit.fetch_for_record(patient_id, record_id, params)
      assert fetched.start_time == done.start_time
      assert fetched.specialist_id == done.specialist_id
    end

    test "doesn't return visit for other patient" do
      patient_id = 1
      record_id = 1

      now = DateTime.utc_now() |> DateTime.to_unix()
      {:ok, _visit} = prepare_visit(patient_id, record_id, now)

      params = %{"limit" => "1"}

      {:ok, [], nil} = Visit.fetch_for_record(2, record_id, params)
    end

    test "doesn't return visit for other record" do
      patient_id = 1
      record_id = 1

      now = DateTime.utc_now() |> DateTime.to_unix()
      {:ok, _visit} = prepare_visit(patient_id, record_id, now)

      params = %{"limit" => "1"}

      {:ok, [], nil} = Visit.fetch_for_record(patient_id, 2, params)
    end
  end
end
