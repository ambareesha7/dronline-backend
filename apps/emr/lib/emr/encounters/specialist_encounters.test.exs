defmodule EMR.Encounters.SpecialistEncountersTest do
  use Postgres.DataCase, async: true

  alias EMR.Encounters.SpecialistEncounters

  describe "get/2" do
    test "return empty list if no Patient Records in database" do
      assert [] = get_result(1, %{})
    end

    test "return list of encounters, filtered by specialist" do
      patient = PatientProfile.Factory.insert(:patient)
      specialist = Authentication.Factory.insert(:verified_and_approved_external)

      record =
        EMR.Factory.insert(:visit_record, patient_id: patient.id, specialist_id: specialist.id)

      specialist_2 = Authentication.Factory.insert(:verified_and_approved_external)

      _ignored_record =
        EMR.Factory.insert(:visit_record, patient_id: patient.id, specialist_id: specialist_2.id)

      assert [
               %{
                 id: result_record_id,
                 start_time: _,
                 end_time: _,
                 state: _,
                 type: :VISIT,
                 patient_id: _
               }
             ] = get_result(specialist.id, %{})

      assert result_record_id == record.id
    end

    test "results are ordered by inserted_at desc" do
      patient = PatientProfile.Factory.insert(:patient)
      specialist = Authentication.Factory.insert(:verified_and_approved_external)

      record_completed_1 =
        EMR.Factory.insert(:completed_record,
          patient_id: patient.id,
          specialist_id: specialist.id,
          inserted_at: ~N[2020-01-01 01:00:00.000000]
        )

      record_completed_2 =
        EMR.Factory.insert(:completed_record,
          patient_id: patient.id,
          specialist_id: specialist.id,
          inserted_at: ~N[2020-01-01 02:00:00.000000]
        )

      record_completed_3 =
        EMR.Factory.insert(:completed_record,
          patient_id: patient.id,
          specialist_id: specialist.id,
          inserted_at: ~N[2020-01-01 03:00:00.000000]
        )

      assert [
               %{
                 id: result_id_1
               },
               %{
                 id: result_id_2
               },
               %{
                 id: result_id_3
               }
             ] = get_result(specialist.id, %{})

      assert result_id_1 == record_completed_3.id
      assert result_id_2 == record_completed_2.id
      assert result_id_3 == record_completed_1.id
    end

    test "filter by state - CANCELED/COMPLETED/PENDING" do
      patient = PatientProfile.Factory.insert(:patient)
      specialist = Authentication.Factory.insert(:verified_and_approved_external)

      record_completed =
        EMR.Factory.insert(
          :completed_record,
          patient_id: patient.id,
          specialist_id: specialist.id
        )

      record_canceled =
        EMR.Factory.insert(:canceled_record,
          patient_id: patient.id,
          specialist_id: specialist.id
        )

      record_pending =
        EMR.Factory.insert(:active_record,
          patient_id: patient.id,
          specialist_id: specialist.id
        )

      assert [
               %{
                 id: record_canceled_id,
                 state: "CANCELED"
               }
             ] = get_result(specialist.id, %{"state_filter" => "CANCELED"})

      assert record_canceled_id == record_canceled.id

      assert [
               %{
                 id: record_completed_id,
                 state: "COMPLETED"
               }
             ] = get_result(specialist.id, %{"state_filter" => "COMPLETED"})

      assert record_completed_id == record_completed.id

      assert [
               %{
                 id: record_pending_id,
                 state: "PENDING"
               }
             ] = get_result(specialist.id, %{"state_filter" => "PENDING"})

      assert record_pending_id == record_pending.id
    end

    test "filter by type - VISIT/AUTO/MANUAL/IN_OFFICE" do
      patient = PatientProfile.Factory.insert(:patient)
      specialist = Authentication.Factory.insert(:verified_and_approved_external)

      EMR.Factory.insert(
        :completed_record,
        patient_id: patient.id,
        specialist_id: specialist.id,
        type: :VISIT,
        inserted_at: ~N[2020-01-01 01:00:00.000000]
      )

      EMR.Factory.insert(
        :completed_record,
        patient_id: patient.id,
        specialist_id: specialist.id,
        type: :IN_OFFICE,
        inserted_at: ~N[2020-01-01 02:00:00.000000]
      )

      EMR.Factory.insert(
        :completed_record,
        patient_id: patient.id,
        specialist_id: specialist.id,
        type: :AUTO,
        inserted_at: ~N[2020-01-01 02:00:00.000000]
      )

      assert [%{type: :VISIT}] = get_result(specialist.id, %{"type_filter" => "VISIT"})

      assert [%{type: :AUTO}] = get_result(specialist.id, %{"type_filter" => "AUTO"})

      assert [%{type: :IN_OFFICE}] = get_result(specialist.id, %{"type_filter" => "IN_OFFICE"})

      assert [] = get_result(specialist.id, %{"type_filter" => "MANUAL"})
    end

    test "filter by day" do
      patient = PatientProfile.Factory.insert(:patient)
      specialist = Authentication.Factory.insert(:verified_and_approved_external)

      record_1 =
        EMR.Factory.insert(
          :completed_record,
          patient_id: patient.id,
          specialist_id: specialist.id
        )

      _record_1_visit =
        insert_pending_visit(
          patient.id,
          specialist.id,
          record_1.id,
          start_time: naive_datetime_to_unix(~N[2020-01-01 01:00:00.000000])
        )

      record_2 =
        EMR.Factory.insert(
          :canceled_record,
          patient_id: patient.id,
          specialist_id: specialist.id
        )

      _record_2_visit =
        insert_pending_visit(
          patient.id,
          specialist.id,
          record_2.id,
          start_time: naive_datetime_to_unix(~N[2020-01-01 01:00:00.000000])
        )

      start_of_first_day =
        ~N[2020-01-01 00:00:00.000000]
        |> DateTime.from_naive!("Etc/UTC")
        |> DateTime.to_unix()

      start_of_second_day =
        ~N[2020-01-02 00:00:00.000000]
        |> DateTime.from_naive!("Etc/UTC")
        |> DateTime.to_unix()

      assert [_, _] = get_result(specialist.id, %{"day_filter" => start_of_first_day})

      assert [] = get_result(specialist.id, %{"day_filter" => start_of_second_day})
    end

    test "pagination works" do
      patient = PatientProfile.Factory.insert(:patient)
      specialist = Authentication.Factory.insert(:verified_and_approved_external)

      record_1 =
        EMR.Factory.insert(
          :completed_record,
          patient_id: patient.id,
          specialist_id: specialist.id,
          inserted_at: ~N[2020-01-01 02:00:00.000000]
        )

      record_2 =
        EMR.Factory.insert(
          :completed_record,
          patient_id: patient.id,
          specialist_id: specialist.id,
          inserted_at: ~N[2020-01-01 01:00:00.000000]
        )

      params = %{"limit" => "1"}
      assert {:ok, [encounter], next_token} = SpecialistEncounters.get(specialist.id, params)
      assert encounter.inserted_at == record_1.inserted_at
      assert NaiveDateTime.from_iso8601!(next_token) == record_2.inserted_at

      params = %{"limit" => "1", "next_token" => next_token}
      assert {:ok, [encounter], nil} = SpecialistEncounters.get(specialist.id, params)
      assert encounter.inserted_at == record_2.inserted_at
    end

    test "Returns correct start/end time." do
      # start_time is:
      # - VISIT/IN_OFFICE type: visit start time
      # - AUTO/MANUAL type: call_recording created_at

      # end_time is:
      # - VISIT/IN_OFFICE type: visit start time + 15 mins
      # - AUTO/MANUAL type: call_recording created_at + duration

      patient = PatientProfile.Factory.insert(:patient)
      specialist = Authentication.Factory.insert(:verified_and_approved_external)
      visit_duration_minutes = 15

      %{id: visit_record_id} =
        EMR.Factory.insert(
          :completed_record,
          patient_id: patient.id,
          specialist_id: specialist.id,
          type: :VISIT,
          inserted_at: ~N[2020-01-01 01:00:00.000000]
        )

      %{id: in_office_record_id} =
        EMR.Factory.insert(
          :completed_record,
          patient_id: patient.id,
          specialist_id: specialist.id,
          type: :IN_OFFICE,
          inserted_at: ~N[2020-01-01 03:00:00.000000]
        )

      %{id: auto_record_id} =
        EMR.Factory.insert(
          :completed_record,
          patient_id: patient.id,
          specialist_id: specialist.id,
          type: :AUTO,
          inserted_at: ~N[2020-01-01 02:00:00.000000]
        )

      _ =
        insert_pending_visit(
          patient.id,
          specialist.id,
          visit_record_id,
          start_time: 1_592_800_000
        )

      _ =
        insert_pending_visit(
          patient.id,
          specialist.id,
          in_office_record_id,
          start_time: 1_600_200_000
        )

      _ =
        EMR.Factory.insert(
          :call_recording,
          record_id: auto_record_id,
          patient_id: patient.id,
          specialist_id: specialist.id,
          duration: 10,
          created_at: 1_596_500_000
        )

      assert [
               %{
                 type: :VISIT,
                 start_time: visit_start_time,
                 end_time: visit_end_time
               }
             ] = get_result(specialist.id, %{"type_filter" => "VISIT"})

      assert [
               %{
                 type: :IN_OFFICE,
                 start_time: in_office_start_time,
                 end_time: in_office_end_time
               }
             ] =
               get_result(specialist.id, %{"type_filter" => "IN_OFFICE"})

      assert [
               %{
                 type: :AUTO,
                 start_time: call_start_time,
                 end_time: call_end_time
               }
             ] = get_result(specialist.id, %{"type_filter" => "AUTO"})

      assert visit_start_time == 1_592_800_000
      assert visit_end_time == 1_592_800_000 + 60 * visit_duration_minutes

      assert in_office_start_time == 1_600_200_000
      assert in_office_end_time == 1_600_200_000 + 60 * visit_duration_minutes

      assert call_start_time == 1_596_500_000
      assert call_end_time == 1_596_500_000 + 10
    end
  end

  defp get_result(specialist_id, params) do
    with {:ok, result, _next_token} <- SpecialistEncounters.get(specialist_id, params) do
      result
    end
  end

  defp insert_pending_visit(patient_id, specialist_id, record_id, options) do
    Repo.insert!(%Visits.PendingVisit{
      id: UUID.uuid4(),
      chosen_medical_category_id: 1,
      patient_id: patient_id,
      record_id: record_id,
      specialist_id: specialist_id,
      start_time: options[:start_time] || 1_592_800_000
    })
  end

  defp naive_datetime_to_unix(naive_date_time) do
    naive_date_time
    |> DateTime.from_naive!("Etc/UTC")
    |> DateTime.to_unix()
  end
end
