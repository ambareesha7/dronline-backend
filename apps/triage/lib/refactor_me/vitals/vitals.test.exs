defmodule Triage.VitalsTest do
  use Postgres.DataCase, async: true

  alias Triage.Vitals

  describe "create/4" do
    test "creates vitals when params are valid" do
      nurse = Authentication.Factory.insert(:specialist, type: "NURSE")
      patient = PatientProfile.Factory.insert(:patient)
      timeline = EMR.Factory.insert(:automatic_record, patient_id: patient.id)

      params = %{
        weight: 183,
        height: 80,
        systolic: 120,
        diastolic: 60,
        pulse: 80,
        ekg_file_url: "http://example.com/ekg.png"
      }

      assert {:ok, %Vitals{}} = Vitals.create(patient.id, timeline.id, nurse.id, params)
    end

    test "returns {:error, changeset} when params aren't valid" do
      nurse = Authentication.Factory.insert(:specialist, type: "NURSE")
      patient = PatientProfile.Factory.insert(:patient)
      timeline = EMR.Factory.insert(:automatic_record, patient_id: patient.id)

      params = %{
        weight: 183,
        height: nil,
        systolic: 120,
        diastolic: 60,
        pulse: 80,
        ekg_file_url: "http://example.com/ekg.png"
      }

      assert {:error, %Ecto.Changeset{}} =
               Vitals.create(patient.id, timeline.id, nurse.id, params)
    end
  end

  describe "update/2" do
    test "update vitals when params are valid" do
      nurse = Authentication.Factory.insert(:specialist, type: "NURSE")
      patient = PatientProfile.Factory.insert(:patient)
      timeline = EMR.Factory.insert(:automatic_record, patient_id: patient.id)

      vitals =
        Triage.Factory.insert(:vitals,
          patient_id: patient.id,
          timeline_id: timeline.id,
          nurse_id: nurse.id
        )

      params = %{
        ekg_file_url: "http://example.com/new.png"
      }

      assert {:ok, %Vitals{} = vitals} = Vitals.update(vitals.id, params)
      assert vitals.ekg_file_url == "http://example.com/new.png"
    end
  end

  describe "fetch_bmi_entries_for_record/3" do
    test "returns vitals for given patient and record" do
      nurse = Authentication.Factory.insert(:specialist, type: "NURSE")
      patient = PatientProfile.Factory.insert(:patient)
      timeline = EMR.Factory.insert(:automatic_record, patient_id: patient.id)

      params = %{
        weight: 183,
        height: 80,
        systolic: 120,
        diastolic: 60,
        pulse: 80,
        ekg_file_url: "http://example.com/ekg.png"
      }

      {:ok, vitals} = Vitals.create(patient.id, timeline.id, nurse.id, params)

      assert {:ok, [fetched], nil} =
               Vitals.fetch_bmi_entries_for_record(patient.id, timeline.id, %{})

      assert vitals.id == fetched.id
    end

    test "doesn't return vitals when patient id is invalid" do
      nurse = Authentication.Factory.insert(:specialist, type: "NURSE")
      patient = PatientProfile.Factory.insert(:patient)
      timeline = EMR.Factory.insert(:automatic_record, patient_id: patient.id)

      params = %{
        weight: 183,
        height: 80,
        systolic: 120,
        diastolic: 60,
        pulse: 80,
        ekg_file_url: "http://example.com/ekg.png"
      }

      {:ok, _vitals} = Vitals.create(patient.id, timeline.id, nurse.id, params)

      assert {:ok, [], nil} = Vitals.fetch_bmi_entries_for_record(0, timeline.id, %{})
    end

    test "doesn't return vitals when record id is invalid" do
      nurse = Authentication.Factory.insert(:specialist, type: "NURSE")
      patient = PatientProfile.Factory.insert(:patient)
      timeline = EMR.Factory.insert(:automatic_record, patient_id: patient.id)

      params = %{
        weight: 183,
        height: 80,
        systolic: 120,
        diastolic: 60,
        pulse: 80,
        ekg_file_url: "http://example.com/ekg.png"
      }

      {:ok, _vitals} = Vitals.create(patient.id, timeline.id, nurse.id, params)

      assert {:ok, [], nil} = Vitals.fetch_bmi_entries_for_record(patient.id, 0, %{})
    end

    test "doesn't return vitals when bmi data is missing" do
      nurse = Authentication.Factory.insert(:specialist, type: "NURSE")
      patient = PatientProfile.Factory.insert(:patient)
      timeline = EMR.Factory.insert(:automatic_record, patient_id: patient.id)

      params = %{
        weight: 0,
        height: 0,
        systolic: 120,
        diastolic: 60,
        pulse: 80,
        ekg_file_url: "http://example.com/ekg.png"
      }

      {:ok, _vitals} = Vitals.create(patient.id, timeline.id, nurse.id, params)

      assert {:ok, [], nil} = Vitals.fetch_bmi_entries_for_record(patient.id, timeline.id, %{})
    end
  end

  describe "fetch_blood_pressure_entries_for_record/3" do
    test "returns vitals for given patient and record" do
      nurse = Authentication.Factory.insert(:specialist, type: "NURSE")
      patient = PatientProfile.Factory.insert(:patient)
      timeline = EMR.Factory.insert(:automatic_record, patient_id: patient.id)

      params = %{
        weight: 183,
        height: 80,
        systolic: 120,
        diastolic: 60,
        pulse: 80,
        ekg_file_url: "http://example.com/ekg.png"
      }

      {:ok, vitals} = Vitals.create(patient.id, timeline.id, nurse.id, params)

      assert {:ok, [fetched], nil} =
               Vitals.fetch_blood_pressure_entries_for_record(patient.id, timeline.id, %{})

      assert vitals.id == fetched.id
    end

    test "doesn't return vitals when patient id is invalid" do
      nurse = Authentication.Factory.insert(:specialist, type: "NURSE")
      patient = PatientProfile.Factory.insert(:patient)
      timeline = EMR.Factory.insert(:automatic_record, patient_id: patient.id)

      params = %{
        weight: 183,
        height: 80,
        systolic: 120,
        diastolic: 60,
        pulse: 80,
        ekg_file_url: "http://example.com/ekg.png"
      }

      {:ok, _vitals} = Vitals.create(patient.id, timeline.id, nurse.id, params)

      assert {:ok, [], nil} = Vitals.fetch_blood_pressure_entries_for_record(0, timeline.id, %{})
    end

    test "doesn't return vitals when record id is invalid" do
      nurse = Authentication.Factory.insert(:specialist, type: "NURSE")
      patient = PatientProfile.Factory.insert(:patient)
      timeline = EMR.Factory.insert(:automatic_record, patient_id: patient.id)

      params = %{
        weight: 183,
        height: 80,
        systolic: 120,
        diastolic: 60,
        pulse: 80,
        ekg_file_url: "http://example.com/ekg.png"
      }

      {:ok, _vitals} = Vitals.create(patient.id, timeline.id, nurse.id, params)

      assert {:ok, [], nil} = Vitals.fetch_blood_pressure_entries_for_record(patient.id, 0, %{})
    end

    test "doesn't return vitals when blood pressure data is missing" do
      nurse = Authentication.Factory.insert(:specialist, type: "NURSE")
      patient = PatientProfile.Factory.insert(:patient)
      timeline = EMR.Factory.insert(:automatic_record, patient_id: patient.id)

      params = %{
        weight: 183,
        height: 80,
        systolic: 0,
        diastolic: 0,
        pulse: 0,
        ekg_file_url: "http://example.com/ekg.png"
      }

      {:ok, _vitals} = Vitals.create(patient.id, timeline.id, nurse.id, params)

      assert {:ok, [], nil} =
               Vitals.fetch_blood_pressure_entries_for_record(patient.id, timeline.id, %{})
    end
  end
end
