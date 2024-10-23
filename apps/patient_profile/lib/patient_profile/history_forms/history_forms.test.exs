defmodule PatientProfile.HistoryFormsTest do
  use Postgres.DataCase, async: true

  alias PatientProfile.HistoryForms

  describe "fetch_by_patient_id/1" do
    test "returns history forms when patient_id is valid" do
      patient = PatientProfile.Factory.insert(:patient)
      history_forms = PatientProfile.Factory.insert(:history_forms, patient_id: patient.id)

      {:ok, fetched} = HistoryForms.fetch_by_patient_id(patient.id)

      assert fetched.id == history_forms.id
    end

    test "returns empty history forms when patient_id is invalid" do
      {:ok, %HistoryForms{id: nil}} = HistoryForms.fetch_by_patient_id(0)
    end
  end

  describe "update/2" do
    test "creates new history forms when they doesn't exist" do
      patient = PatientProfile.Factory.insert(:patient)
      params = %{allergy: <<10, 0>>}

      {:ok, %HistoryForms{allergy: <<10, 0>>}} = HistoryForms.update(params, patient.id)
    end

    test "updates history forms when they exists" do
      patient = PatientProfile.Factory.insert(:patient)

      _forms =
        PatientProfile.Factory.insert(:history_forms, patient_id: patient.id, allergy: <<10, 0>>)

      params = %{allergy: <<20, 0>>}

      {:ok, %HistoryForms{allergy: <<20, 0>>}} = HistoryForms.update(params, patient.id)
    end
  end
end
