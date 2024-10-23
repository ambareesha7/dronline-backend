defmodule EMR.PatientRecords.PatientRecordTest do
  use Postgres.DataCase, async: true

  alias EMR.PatientRecords.PatientRecord

  describe "get_main_specialist_ids/1" do
    test "returns created_by_specialist_id if present" do
      record = %PatientRecord{created_by_specialist_id: 1}

      assert PatientRecord.get_main_specialist_ids(record) == [1]
    end

    test "returns empty list for records created by patient" do
      record = %PatientRecord{created_by_specialist_id: nil}

      assert PatientRecord.get_main_specialist_ids(record) == []
    end
  end

  describe "create_manual_record/2" do
    test "succeds" do
      patient = PatientProfile.Factory.insert(:patient)
      specialist = Authentication.Factory.insert(:specialist)

      assert {:ok, _record} = PatientRecord.create_manual_record(patient.id, specialist.id)
    end

    test "succeds when auto record exists" do
      patient = PatientProfile.Factory.insert(:patient)
      _timeline = EMR.Factory.insert(:automatic_record, patient_id: patient.id)
      specialist = Authentication.Factory.insert(:specialist)

      assert {:ok, _record} = PatientRecord.create_manual_record(patient.id, specialist.id)
    end

    test "succeds when other specialist's manual record exist" do
      patient = PatientProfile.Factory.insert(:patient)
      specialist1 = Authentication.Factory.insert(:specialist)
      specialist2 = Authentication.Factory.insert(:specialist)

      assert {:ok, _record} = PatientRecord.create_manual_record(patient.id, specialist1.id)
      assert {:ok, _record} = PatientRecord.create_manual_record(patient.id, specialist2.id)
    end

    test "succeds when other patient's manual record exist" do
      patient1 = PatientProfile.Factory.insert(:patient)
      patient2 = PatientProfile.Factory.insert(:patient)
      specialist = Authentication.Factory.insert(:specialist)

      assert {:ok, _record} = PatientRecord.create_manual_record(patient1.id, specialist.id)
      assert {:ok, _record} = PatientRecord.create_manual_record(patient2.id, specialist.id)
    end

    test "fails when specialist already has manual record for given patient" do
      patient = PatientProfile.Factory.insert(:patient)
      specialist = Authentication.Factory.insert(:specialist)

      assert {:ok, _record} = PatientRecord.create_manual_record(patient.id, specialist.id)
      assert {:error, changeset} = PatientRecord.create_manual_record(patient.id, specialist.id)

      error_msg = "you can have only one active record per patient"
      assert error_msg in errors_on(changeset)._manual_record_limit
    end

    test "succeds when specialist has closed manual record for given patient" do
      patient = PatientProfile.Factory.insert(:patient)
      specialist = Authentication.Factory.insert(:specialist)

      assert {:ok, record} = PatientRecord.create_manual_record(patient.id, specialist.id)
      PatientRecord.close(patient.id, record.id)

      assert {:ok, _record} = PatientRecord.create_manual_record(patient.id, specialist.id)
    end
  end

  describe "create_visit_record/2" do
    test "creates record of VISIT type" do
      patient = PatientProfile.Factory.insert(:patient)
      specialist_id = 1

      assert {:ok, record} = PatientRecord.create_visit_record(patient.id, specialist_id)

      assert record.patient_id == patient.id
      assert record.with_specialist_id == specialist_id
      assert record.type == :VISIT
    end
  end

  describe "fetch_or_create_automatic/1" do
    test "returns new automatic record when there was none" do
      patient = PatientProfile.Factory.insert(:patient)

      assert {:ok, created_record} = PatientRecord.fetch_or_create_automatic(patient.id)
      assert created_record.patient_id == patient.id
    end

    test "returns current automatic record when it exists" do
      patient = PatientProfile.Factory.insert(:patient)
      {:ok, record} = EMR.fetch_or_create_automatic_record(patient.id)

      {:ok, fetched_record} = PatientRecord.fetch_or_create_automatic(patient.id)
      assert fetched_record.id == record.id
    end
  end

  describe "Patient's insurance_account_id get's assigned to all created records" do
    test "Record's insurance_account_id is set" do
      patient = Insurance.Factory.insert(:patient, [])
      specialist = Authentication.Factory.insert(:specialist)

      country = Postgres.Factory.insert(:country, [])

      insurance_provider =
        Insurance.Factory.insert(:provider, name: "provider_name", country_id: country.id)

      insurance_account =
        Insurance.Factory.insert(:account,
          provider_id: insurance_provider.id,
          patient_id: patient.id,
          member_id: "member_id"
        )

      patient
      |> Ecto.Changeset.change(insurance_account_id: insurance_account.id)
      |> Postgres.Repo.update!()

      {:ok, visit_record} = PatientRecord.create_visit_record(patient.id, specialist.id)
      {:ok, automatic_record} = PatientRecord.fetch_or_create_automatic(patient.id)
      {:ok, manual_record} = PatientRecord.create_manual_record(patient.id, specialist.id)

      assert insurance_account.id == visit_record.insurance_account_id
      assert insurance_account.id == automatic_record.insurance_account_id
      assert insurance_account.id == manual_record.insurance_account_id
    end
  end

  describe "fetch/2" do
    test "when next token is missing" do
      patient = PatientProfile.Factory.insert(:patient)
      timeline = EMR.Factory.insert(:automatic_record, patient_id: patient.id)

      params = %{"limit" => "1"}

      {:ok, [fetched], nil} = PatientRecord.fetch(patient.id, params)
      assert fetched.id == timeline.id
    end

    test "when next token is blank string" do
      patient = PatientProfile.Factory.insert(:patient)
      timeline = EMR.Factory.insert(:automatic_record, patient_id: patient.id)

      params = %{"limit" => "1", "next_token" => ""}

      {:ok, [fetched], nil} = PatientRecord.fetch(patient.id, params)
      assert fetched.id == timeline.id
    end

    test "when next token is valid" do
      patient = PatientProfile.Factory.insert(:patient)
      timeline = EMR.Factory.insert(:automatic_record, patient_id: patient.id)

      params = %{"limit" => "1", "next_token" => to_string(timeline.id)}

      {:ok, [fetched], nil} = PatientRecord.fetch(patient.id, params)
      assert fetched.id == timeline.id
    end

    test "returns next_token when there's more records" do
      patient = PatientProfile.Factory.insert(:patient)

      record = EMR.Factory.insert(:automatic_record, patient_id: patient.id)
      :ok = PatientRecord.close(patient.id, record.id)

      record2 = EMR.Factory.insert(:automatic_record, patient_id: patient.id)

      params = %{"limit" => "1", "next_token" => to_string(record2.id)}

      {:ok, [fetched], new_next_token} = PatientRecord.fetch(patient.id, params)
      assert fetched.id == record2.id
      assert new_next_token == record.id
    end

    test "doesn't return other patients records" do
      patient = PatientProfile.Factory.insert(:patient)
      patient2 = PatientProfile.Factory.insert(:patient)

      _timeline = EMR.Factory.insert(:automatic_record, patient_id: patient2.id)

      {:ok, [], nil} = PatientRecord.fetch(patient.id, %{})
    end

    test "returns sorted with the newest at top" do
      patient = PatientProfile.Factory.insert(:patient)

      record1 = EMR.Factory.insert(:automatic_record, patient_id: patient.id)
      :ok = PatientRecord.close(patient.id, record1.id)

      record2 = EMR.Factory.insert(:automatic_record, patient_id: patient.id)
      :ok = PatientRecord.close(patient.id, record2.id)

      record3 = EMR.Factory.insert(:automatic_record, patient_id: patient.id)

      params = %{}
      {:ok, records, nil} = PatientRecord.fetch(patient.id, params)
      assert Enum.at(records, 0).id == record3.id
      assert Enum.at(records, 1).id == record2.id
      assert Enum.at(records, 2).id == record1.id
    end

    test "when filter is set to ONGOING" do
      patient = PatientProfile.Factory.insert(:patient)
      specialist = Authentication.Factory.insert(:verified_and_approved_external)

      ignored_ended_record = EMR.Factory.insert(:automatic_record, patient_id: patient.id)
      :ok = PatientRecord.close(patient.id, ignored_ended_record.id)

      _ignored_canceled_record =
        EMR.Factory.insert(
          :canceled_record,
          patient_id: patient.id,
          specialist_id: specialist.id
        )

      ongoing_record = EMR.Factory.insert(:automatic_record, patient_id: patient.id)

      params = %{"status" => "ONGOING"}

      {:ok, [fetched], nil} = PatientRecord.fetch(patient.id, params)
      assert fetched.id == ongoing_record.id
    end

    test "when filter is set to ENDED" do
      patient = PatientProfile.Factory.insert(:patient)

      ended_record = EMR.Factory.insert(:automatic_record, patient_id: patient.id)
      :ok = PatientRecord.close(patient.id, ended_record.id)

      _ongoing_record = EMR.Factory.insert(:automatic_record, patient_id: patient.id)

      params = %{"status" => "ENDED"}

      {:ok, [fetched], nil} = PatientRecord.fetch(patient.id, params)
      assert fetched.id == ended_record.id
    end
  end

  describe "fetch_by_id/2" do
    test "returns record when it exists" do
      patient = PatientProfile.Factory.insert(:patient)
      timeline = EMR.Factory.insert(:automatic_record, patient_id: patient.id)

      {:ok, record} = PatientRecord.fetch_by_id(timeline.id, patient.id)

      assert record.id == timeline.id
    end

    test "returns error when timeline_id is invalid" do
      patient = PatientProfile.Factory.insert(:patient)
      _timeline = EMR.Factory.insert(:automatic_record, patient_id: patient.id)

      {:error, :not_found} = PatientRecord.fetch_by_id(0, patient.id)
    end

    test "returns error when patient_id is invalid" do
      patient = PatientProfile.Factory.insert(:patient)
      timeline = EMR.Factory.insert(:automatic_record, patient_id: patient.id)

      {:error, :not_found} = PatientRecord.fetch_by_id(timeline.id, 0)
    end

    test "preloads insurance information" do
      patient = PatientProfile.Factory.insert(:patient)

      country = Postgres.Factory.insert(:country, [])

      insurance_provider =
        Insurance.Factory.insert(:provider, name: "provider_name", country_id: country.id)

      insurance_account =
        Insurance.Factory.insert(:account,
          provider_id: insurance_provider.id,
          patient_id: patient.id,
          member_id: "member_id"
        )

      timeline =
        EMR.Factory.insert(
          :completed_record,
          patient_id: patient.id,
          insurance_account_id: insurance_account.id
        )

      {:ok,
       %{
         id: id,
         insurance_account: %{
           insurance_provider: %{name: "provider_name"}
         }
       }} = PatientRecord.fetch_by_id(timeline.id, patient.id)

      assert id == timeline.id
    end
  end

  describe "close/2" do
    test "closes active record and returns :ok" do
      patient = PatientProfile.Factory.insert(:patient)
      record = EMR.Factory.insert(:automatic_record, patient_id: patient.id)

      assert :ok = PatientRecord.close(patient.id, record.id)

      {:ok, record} = PatientRecord.fetch_by_id(record.id, patient.id)
      assert record.closed_at
    end

    test "returns :ok when record is already closed" do
      patient = PatientProfile.Factory.insert(:patient)
      record = EMR.Factory.insert(:automatic_record, patient_id: patient.id)

      :ok = PatientRecord.close(patient.id, record.id)

      assert :ok = PatientRecord.close(patient.id, record.id)
    end

    test "shouldn't override closed_at when called second time" do
      patient = PatientProfile.Factory.insert(:patient)
      record = EMR.Factory.insert(:automatic_record, patient_id: patient.id)

      :ok = PatientRecord.close(patient.id, record.id)
      {:ok, record1} = PatientRecord.fetch_by_id(record.id, patient.id)

      :ok = PatientRecord.close(patient.id, record.id)
      {:ok, record2} = PatientRecord.fetch_by_id(record.id, patient.id)

      assert record2.closed_at == record1.closed_at
    end

    test "returns error when record doesn't exist" do
      patient = PatientProfile.Factory.insert(:patient)
      record = EMR.Factory.insert(:automatic_record, patient_id: patient.id)

      assert {:error, :not_found} = PatientRecord.close(patient.id, 0)
      assert {:error, :not_found} = PatientRecord.close(0, record.id)
    end
  end

  describe "cancel/2" do
    test "cancels active record and returns :ok" do
      patient = PatientProfile.Factory.insert(:patient)
      record = EMR.Factory.insert(:automatic_record, patient_id: patient.id)

      assert :ok = PatientRecord.cancel(patient.id, record.id)

      {:ok, record} = PatientRecord.fetch_by_id(record.id, patient.id)
      refute record.closed_at
      assert record.canceled_at
      assert record.active == false
    end
  end

  describe "set_with_whom_value/3" do
    test "sets 'with whom' value when isn't set yet" do
      specialist_id = 1

      patient = PatientProfile.Factory.insert(:patient)
      record = EMR.Factory.insert(:automatic_record, patient_id: patient.id)

      PatientRecord.set_with_whom_value(patient.id, record.id, specialist_id)

      {:ok, fetched_record} = PatientRecord.fetch_by_id(record.id, patient.id)
      assert fetched_record.with_specialist_id == specialist_id
    end

    test "does nothing if 'with whom' value is already set" do
      specialist1_id = 1
      specialist2_id = 2

      patient = PatientProfile.Factory.insert(:patient)
      record = EMR.Factory.insert(:automatic_record, patient_id: patient.id)

      PatientRecord.set_with_whom_value(patient.id, record.id, specialist1_id)
      PatientRecord.set_with_whom_value(patient.id, record.id, specialist2_id)

      {:ok, fetched_record} = PatientRecord.fetch_by_id(record.id, patient.id)
      assert fetched_record.with_specialist_id == specialist1_id
      refute fetched_record.with_specialist_id == specialist2_id
    end

    test "ignores records of type other than AUTO" do
      specialist_id = 1

      patient = PatientProfile.Factory.insert(:patient)
      record = EMR.Factory.insert(:manual_record, patient_id: patient.id)

      PatientRecord.set_with_whom_value(patient.id, record.id, specialist_id)
      {:ok, fetched_record} = PatientRecord.fetch_by_id(record.id, patient.id)

      assert fetched_record.with_specialist_id == record.with_specialist_id
      refute fetched_record.with_specialist_id == specialist_id
    end
  end
end
