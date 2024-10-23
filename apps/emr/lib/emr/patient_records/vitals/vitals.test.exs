defmodule EMR.PatientRecords.VitalsTest do
  use Postgres.DataCase, async: true

  alias EMR.PatientRecords.Vitals

  defp vitals_params do
    %{
      height: 180,
      weight: 80,
      blood_pressure_systolic: 100,
      blood_pressure_diastolic: 70,
      pulse: 80,
      respiratory_rate: 200,
      body_temperature: 36.6,
      physical_exam: "test"
    }
  end

  describe "add_newest/4" do
    test "creates vitals_entry when params are valid" do
      patient_id = 1
      record_id = 2
      nurse_id = 3

      params = vitals_params()

      assert {:ok, _vitals} = Vitals.add_newest(patient_id, record_id, nurse_id, params)
    end

    test "returns changeset when params are invalid" do
      patient_id = 1
      record_id = 2
      nurse_id = 3

      params = %{}

      assert {:error, %Ecto.Changeset{}} =
               Vitals.add_newest(patient_id, record_id, nurse_id, params)
    end
  end

  describe "get_latest/1" do
    test "returns nil if patient don't have any vitals provided yet" do
      patient_id = 1

      assert Vitals.get_latest(patient_id) == nil
    end

    test "doesn't return vitals of different patient" do
      patient1_id = 1
      patient2_id = 2

      record_id = 3
      nurse_id = 4
      params = vitals_params()

      {:ok, _vitals} = Vitals.add_newest(patient2_id, record_id, nurse_id, params)

      assert Vitals.get_latest(patient1_id) == nil
    end

    test "returns only latest provided vitals if patient has more than one" do
      patient_id = 1
      record_id = 2
      nurse_id = 3
      params = vitals_params()

      {:ok, _vitals1} = Vitals.add_newest(patient_id, record_id, nurse_id, params)
      {:ok, vitals2} = Vitals.add_newest(patient_id, record_id, nurse_id, params)

      returned_vitals = Vitals.get_latest(patient_id)
      assert returned_vitals.id == vitals2.id
    end
  end

  describe "fetch_history/2" do
    test "returns correct entries when next token is missing" do
      patient_id = 1
      record_id = 2
      nurse_id = 3
      params = vitals_params()

      {:ok, vitals1} = Vitals.add_newest(patient_id, record_id, nurse_id, params)
      {:ok, vitals2} = Vitals.add_newest(patient_id, record_id, nurse_id, params)

      params = %{"limit" => "1"}

      {:ok, [returned_vitals], next_token} = Vitals.fetch_history(patient_id, params)

      assert returned_vitals.id == vitals2.id
      assert next_token == NaiveDateTime.to_iso8601(vitals1.inserted_at)
    end

    test "returns correct entries when next token is present" do
      patient_id = 1
      record_id = 2
      nurse_id = 3
      params = vitals_params()

      {:ok, vitals1} = Vitals.add_newest(patient_id, record_id, nurse_id, params)
      {:ok, _vitals2} = Vitals.add_newest(patient_id, record_id, nurse_id, params)

      params = %{"limit" => "1", "next_token" => NaiveDateTime.to_iso8601(vitals1.inserted_at)}

      {:ok, [returned_vitals], next_token} = Vitals.fetch_history(patient_id, params)

      assert returned_vitals.id == vitals1.id
      assert next_token == ""
    end

    test "doesn't return vitals for other patient" do
      patient_id = 1
      record_id = 2
      nurse_id = 3
      params = vitals_params()

      other_patient_id = 4

      {:ok, _vitals} = Vitals.add_newest(patient_id, record_id, nurse_id, params)

      params = %{"limit" => "1"}

      {:ok, [], ""} = Vitals.fetch_history(other_patient_id, params)
    end
  end

  describe "fetch_history_for_record/3" do
    test "returns correct entries when next token is missing" do
      patient_id = 1
      record_id = 2
      nurse_id = 3
      params = vitals_params()

      {:ok, vitals1} = Vitals.add_newest(patient_id, record_id, nurse_id, params)
      {:ok, vitals2} = Vitals.add_newest(patient_id, record_id, nurse_id, params)

      params = %{"limit" => "1"}

      {:ok, [returned_vitals], next_token} =
        Vitals.fetch_history_for_record(patient_id, record_id, params)

      assert returned_vitals.id == vitals2.id
      assert next_token == NaiveDateTime.to_iso8601(vitals1.inserted_at)
    end

    test "returns correct entries when next token is present" do
      patient_id = 1
      record_id = 2
      nurse_id = 3
      params = vitals_params()

      {:ok, vitals1} = Vitals.add_newest(patient_id, record_id, nurse_id, params)
      {:ok, _vitals2} = Vitals.add_newest(patient_id, record_id, nurse_id, params)

      params = %{"limit" => "1", "next_token" => NaiveDateTime.to_iso8601(vitals1.inserted_at)}

      {:ok, [returned_vitals], next_token} =
        Vitals.fetch_history_for_record(patient_id, record_id, params)

      assert returned_vitals.id == vitals1.id
      assert next_token == ""
    end

    test "doesn't return vitals for other patient" do
      patient_id = 1
      record_id = 2
      nurse_id = 3
      params = vitals_params()

      other_patient_id = 4

      {:ok, _vitals} = Vitals.add_newest(patient_id, record_id, nurse_id, params)

      params = %{"limit" => "1"}

      {:ok, [], ""} = Vitals.fetch_history_for_record(other_patient_id, record_id, params)
    end

    test "doesn't return vitals for other records" do
      patient_id = 1
      record_id = 2
      nurse_id = 3
      params = vitals_params()

      other_record_id = 4

      {:ok, _vitals} = Vitals.add_newest(patient_id, record_id, nurse_id, params)

      params = %{"limit" => "1"}

      {:ok, [], ""} = Vitals.fetch_history_for_record(patient_id, other_record_id, params)
    end
  end
end
