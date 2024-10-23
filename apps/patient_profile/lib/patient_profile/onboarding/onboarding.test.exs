defmodule PatientProfile.OnboardingTest do
  use Postgres.DataCase, async: true

  alias PatientProfile.Onboarding

  describe "finished/1" do
    test "updates patient's onboarding_completed flag" do
      patient = PatientProfile.Factory.insert(:patient)

      :ok = Onboarding.finished(patient.id)

      {:ok, %Onboarding{onboarding_completed: true}} = Repo.fetch(Onboarding, patient.id)
    end
  end
end
