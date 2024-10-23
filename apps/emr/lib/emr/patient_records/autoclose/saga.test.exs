defmodule EMR.PatientRecords.Autoclose.SagaTest do
  use Postgres.DataCase, async: true

  alias EMR.PatientRecords.Autoclose.Saga

  describe "register_pending_medical_summary/3" do
    test "adds pending summary to state" do
      patient_id = 1
      record_id = 2
      specialist_id = 3

      :ok = Saga.register_pending_medical_summary(patient_id, record_id, specialist_id)
      saga = Repo.get_by(Saga, patient_id: patient_id, record_id: record_id)

      assert saga.state == [{:pending_summary, specialist_id}]
    end

    test "doesn't allow to add same pending summary to state twice" do
      patient_id = 1
      record_id = 2
      specialist_id = 3

      :ok = Saga.register_pending_medical_summary(patient_id, record_id, specialist_id)
      :ok = Saga.register_pending_medical_summary(patient_id, record_id, specialist_id)
      saga = Repo.get_by(Saga, patient_id: patient_id, record_id: record_id)

      assert saga.state == [{:pending_summary, specialist_id}]
    end
  end

  describe "register_provided_medical_summary/3" do
    test "removes pending summary from state" do
      patient_id = 1
      record_id = 2
      specialist_id = 3

      :ok = Saga.register_pending_medical_summary(patient_id, record_id, specialist_id)
      :ok = Saga.register_provided_medical_summary(patient_id, record_id, specialist_id)
      saga = Repo.get_by(Saga, patient_id: patient_id, record_id: record_id)

      assert saga.state == []
    end

    test "doesn't remove pening summary of another specialist from state" do
      patient_id = 1
      record_id = 2
      specialist_id = 3
      another_specialist_id = 4

      :ok = Saga.register_pending_medical_summary(patient_id, record_id, specialist_id)
      :ok = Saga.register_provided_medical_summary(patient_id, record_id, another_specialist_id)
      saga = Repo.get_by(Saga, patient_id: patient_id, record_id: record_id)

      assert saga.state == [{:pending_summary, specialist_id}]
    end
  end

  describe "register_dispatch_request/3" do
    test "adds dispatch request to state" do
      patient_id = 1
      record_id = 2
      dispatch_request_id = UUID.uuid4()

      :ok = Saga.register_dispatch_request(patient_id, record_id, dispatch_request_id)
      saga = Repo.get_by(Saga, patient_id: patient_id, record_id: record_id)

      assert saga.state == [{:dispatch_request, dispatch_request_id}]
    end

    test "doesn't allow to add same dispatch request to state twice" do
      patient_id = 1
      record_id = 2
      dispatch_request_id = UUID.uuid4()

      :ok = Saga.register_dispatch_request(patient_id, record_id, dispatch_request_id)
      :ok = Saga.register_dispatch_request(patient_id, record_id, dispatch_request_id)
      saga = Repo.get_by(Saga, patient_id: patient_id, record_id: record_id)

      assert saga.state == [{:dispatch_request, dispatch_request_id}]
    end
  end

  describe "register_dispatch_end/3" do
    test "removes dispatch request from state" do
      patient_id = 1
      record_id = 2
      dispatch_request_id = UUID.uuid4()

      :ok = Saga.register_dispatch_request(patient_id, record_id, dispatch_request_id)
      :ok = Saga.register_dispatch_end(patient_id, record_id, dispatch_request_id)
      saga = Repo.get_by(Saga, patient_id: patient_id, record_id: record_id)

      assert saga.state == []
    end
  end

  test "closes record when all necessary actions are finished" do
    patient = PatientProfile.Factory.insert(:patient)
    record = EMR.Factory.insert(:automatic_record, patient_id: patient.id)

    specialist_id = 1
    dispatch_request_id = UUID.uuid4()

    :ok = Saga.register_pending_medical_summary(patient.id, record.id, specialist_id)
    :ok = Saga.register_dispatch_request(patient.id, record.id, dispatch_request_id)
    :ok = Saga.register_dispatch_end(patient.id, record.id, dispatch_request_id)

    refetched_record =
      Repo.get_by(EMR.PatientRecords.PatientRecord, patient_id: patient.id, id: record.id)

    refute refetched_record.closed_at

    :ok = Saga.register_provided_medical_summary(patient.id, record.id, specialist_id)

    refetched_record =
      Repo.get_by(EMR.PatientRecords.PatientRecord, patient_id: patient.id, id: record.id)

    assert refetched_record.closed_at
  end
end
