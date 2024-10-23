defmodule PatientProfile.BMITest do
  use Postgres.DataCase, async: true

  alias PatientProfile.BMI

  describe "fetch_by_patient_id/1" do
    test "returns bmi when patient_id is valid" do
      patient = PatientProfile.Factory.insert(:patient)
      bmi = PatientProfile.Factory.insert(:bmi, patient_id: patient.id)

      {:ok, fetched} = BMI.fetch_by_patient_id(patient.id)

      assert fetched.id == bmi.id
    end

    test "returns empty bmi when patient_id is invalid" do
      {:ok, %BMI{id: nil}} = BMI.fetch_by_patient_id(0)
    end
  end

  describe "update/2" do
    test "creates new bmi when it doesn't exist" do
      patient = PatientProfile.Factory.insert(:patient)

      params = %{
        height: 170,
        weight: 60
      }

      {:ok, %BMI{weight: 60}} = BMI.update(params, patient.id)
    end

    test "updates bmi when it exists" do
      patient = PatientProfile.Factory.insert(:patient)
      _bmi = PatientProfile.Factory.insert(:bmi, patient_id: patient.id, weight: 60)
      params = %{weight: 70}

      {:ok, %BMI{weight: 70}} = BMI.update(params, patient.id)
    end

    test "returns validation errors" do
      patient = PatientProfile.Factory.insert(:patient)
      _bmi = PatientProfile.Factory.insert(:bmi, patient_id: patient.id)
      params = %{weight: nil}

      {:error, %Ecto.Changeset{}} = BMI.update(params, patient.id)
    end
  end
end
