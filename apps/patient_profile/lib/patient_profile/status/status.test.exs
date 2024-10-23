defmodule PatientProfile.StatusTest do
  use Postgres.DataCase, async: true

  alias PatientProfile.Status

  test "fetch_by_patient_id/1" do
    patient = PatientProfile.Factory.insert(:patient)

    {:ok, %Status{onboarding_completed: false}} = Status.fetch_by_patient_id(patient.id)
  end
end
