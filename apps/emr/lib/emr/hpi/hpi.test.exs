defmodule EMR.HPITest do
  use Postgres.DataCase, async: true

  alias EMR.HPI

  describe "fetch_last_for_timeline_id/2" do
    test "returns the last hpi when timeline_id is valid" do
      patient = PatientProfile.Factory.insert(:patient)
      record = EMR.Factory.insert(:automatic_record, patient_id: patient.id)

      _hpi = EMR.Factory.insert(:hpi, patient_id: patient.id, timeline_id: record.id)
      hpi2 = EMR.Factory.insert(:hpi, patient_id: patient.id, timeline_id: record.id)

      assert {:ok, fetched} = HPI.fetch_last_for_timeline_id(patient.id, record.id)

      assert fetched.id == hpi2.id
    end

    test "returns empty hpi when there is no hpi for given record" do
      patient = PatientProfile.Factory.insert(:patient)
      record = EMR.Factory.insert(:automatic_record, patient_id: patient.id)

      assert {:ok, %HPI{id: nil}} = HPI.fetch_last_for_timeline_id(patient.id, record.id)
    end
  end

  describe "fetch_history_for_timeline_id/1" do
    test "returns all hpis when timeline_id is valid" do
      patient = PatientProfile.Factory.insert(:patient)
      timeline = EMR.Factory.insert(:automatic_record, patient_id: patient.id)

      _hpi1 = EMR.Factory.insert(:hpi, patient_id: patient.id, timeline_id: timeline.id)
      _hpi2 = EMR.Factory.insert(:hpi, patient_id: patient.id, timeline_id: timeline.id)

      assert {:ok, fetched} = HPI.fetch_history_for_timeline_id(timeline.id)

      assert length(fetched) == 2
    end

    test "returns empty {:ok, []} when there is no hpi for given record" do
      assert {:ok, []} = HPI.fetch_history_for_timeline_id(0)
    end
  end

  describe "register_history/3" do
    test "succeeds when there is not hpi for given record" do
      patient = PatientProfile.Factory.insert(:patient)
      timeline = EMR.Factory.insert(:automatic_record, patient_id: patient.id)

      form = EMR.Factory.valid_hpi_form()
      assert {:ok, _hpi} = HPI.register_history(patient.id, timeline.id, form)
    end

    test "do nothing when there is last hpi for given record hasn't changed" do
      patient = PatientProfile.Factory.insert(:patient)
      timeline = EMR.Factory.insert(:automatic_record, patient_id: patient.id)

      form = EMR.Factory.valid_hpi_form()
      hpi = EMR.Factory.insert(:hpi, patient_id: patient.id, timeline_id: timeline.id, form: form)
      assert {:ok, fetched_hpi} = HPI.register_history(patient.id, timeline.id, form)
      assert hpi.id == fetched_hpi.id
    end

    test "save as new hpi when there is last hpi for given record has changed" do
      patient = PatientProfile.Factory.insert(:patient)
      timeline = EMR.Factory.insert(:automatic_record, patient_id: patient.id)

      form = EMR.Factory.valid_hpi_form()
      hpi = EMR.Factory.insert(:hpi, patient_id: patient.id, timeline_id: timeline.id, form: form)

      new_form = EMR.Factory.valid_hpi_form()

      assert {:ok, fetched_hpi} = HPI.register_history(patient.id, timeline.id, new_form)

      refute hpi.id == fetched_hpi.id
      refute hpi.inserted_at == fetched_hpi.inserted_at
    end

    test "doesn't allow empty template" do
      assert_raise(RuntimeError, "invalid form template", fn ->
        form = Proto.Forms.Form.new()
        HPI.register_history(1, 1, form)
      end)
    end
  end
end
