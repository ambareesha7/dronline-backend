defmodule Calls.HPI.RegisterHistoryTest do
  use Postgres.DataCase, async: true

  test "success when timeline doesn't exisit" do
    patient = PatientProfile.Factory.insert(:patient)

    assert {:ok, hpi} = Calls.HPI.RegisterHistory.call(patient.id, EMR.Factory.valid_hpi_form())

    assert hpi.form.completed
  end

  test "success when timeline exisits" do
    patient = PatientProfile.Factory.insert(:patient)
    _timeline = EMR.Factory.insert(:automatic_record, patient_id: patient.id)

    assert {:ok, hpi} = Calls.HPI.RegisterHistory.call(patient.id, EMR.Factory.valid_hpi_form())

    assert hpi.form.completed
  end

  test "success when other hpi exisits" do
    patient = PatientProfile.Factory.insert(:patient)
    timeline = EMR.Factory.insert(:automatic_record, patient_id: patient.id)

    EMR.Factory.insert(:hpi, patient_id: patient.id, timeline_id: timeline.id)

    assert {:ok, hpi} = Calls.HPI.RegisterHistory.call(patient.id, EMR.Factory.valid_hpi_form())

    assert hpi.form.completed
  end
end
