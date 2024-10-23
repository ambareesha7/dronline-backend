defmodule PatientProfile.BasicInfoTest do
  use Postgres.DataCase, async: true

  alias PatientProfile.BasicInfo

  describe "fetch_by_patient_id/1" do
    test "returns basic_info when patient_id is valid" do
      patient = PatientProfile.Factory.insert(:patient)
      basic_info = PatientProfile.Factory.insert(:basic_info, patient_id: patient.id)

      {:ok, fetched} = BasicInfo.fetch_by_patient_id(patient.id)

      assert fetched.id == basic_info.id
    end

    test "returns empty basic_info when patient_id is invalid" do
      assert {:ok, %BasicInfo{id: nil}} = BasicInfo.fetch_by_patient_id(0)
    end

    test "returns basic_info patient-provided avatar" do
      patient = PatientProfile.Factory.insert(:patient)

      _basic_info =
        PatientProfile.Factory.insert(:basic_info,
          patient_id: patient.id,
          avatar_resource_path: "/test"
        )

      {:ok, fetched} = BasicInfo.fetch_by_patient_id(patient.id)

      assert fetched.avatar_resource_path == "/test"
    end

    test "returns basic_info with default avatar if patient (man) doesn't provided one" do
      patient = PatientProfile.Factory.insert(:patient)

      _basic_info =
        PatientProfile.Factory.insert(:basic_info,
          patient_id: patient.id,
          gender: "MALE",
          birth_date: ~D[1950-01-01]
        )

      {:ok, basic_info} = BasicInfo.fetch_by_patient_id(patient.id)

      assert basic_info.avatar_resource_path == "/man_test_default_avatar"
    end

    test "returns basic_info with default avatar if patient (woman) doesn't provided one" do
      patient = PatientProfile.Factory.insert(:patient)

      _basic_info =
        PatientProfile.Factory.insert(:basic_info,
          patient_id: patient.id,
          title: "MS",
          gender: "FEMALE",
          birth_date: ~D[1950-01-01]
        )

      {:ok, basic_info} = BasicInfo.fetch_by_patient_id(patient.id)

      assert basic_info.avatar_resource_path == "/woman_test_default_avatar"
    end

    test "returns basic_info with default avatar if patient (boy) doesn't provided one" do
      patient = PatientProfile.Factory.insert(:patient)

      _basic_info =
        PatientProfile.Factory.insert(:basic_info,
          patient_id: patient.id,
          gender: "MALE",
          birth_date: Date.utc_today()
        )

      {:ok, basic_info} = BasicInfo.fetch_by_patient_id(patient.id)

      assert basic_info.avatar_resource_path == "/boy_test_default_avatar"
    end

    test "returns basic_info with default avatar if patient (girl) doesn't provided one" do
      patient = PatientProfile.Factory.insert(:patient)

      _basic_info =
        PatientProfile.Factory.insert(:basic_info,
          patient_id: patient.id,
          gender: "FEMALE",
          birth_date: Date.utc_today()
        )

      {:ok, basic_info} = BasicInfo.fetch_by_patient_id(patient.id)

      assert basic_info.avatar_resource_path == "/girl_test_default_avatar"
    end

    test "returns basic_info with default avatar if patient (unknown age and gender) doesn't provided one" do
      patient = PatientProfile.Factory.insert(:patient)

      _basic_info =
        PatientProfile.Factory.insert(:basic_info,
          patient_id: patient.id,
          gender: nil,
          birth_date: nil
        )

      {:ok, basic_info} = BasicInfo.fetch_by_patient_id(patient.id)

      assert basic_info.avatar_resource_path == "/other_test_default_avatar"
    end
  end

  describe "update/2" do
    test "creates new basic_info when it doesn't exist" do
      patient = PatientProfile.Factory.insert(:patient)

      params = %{
        title: "MR",
        gender: "MALE",
        first_name: "Ahmed",
        last_name: "Ahmed",
        birth_date: ~D[1992-11-30],
        email: "ahmedahmed@ahmed.com",
        avatar_resource_path: "/avatar.jpg"
      }

      assert {:ok, %BasicInfo{first_name: "Ahmed"} = basic_info} =
               BasicInfo.update(params, patient.id)

      Enum.each(params, fn {key, value} ->
        assert Map.get(basic_info, key) == value
      end)
    end

    test "creates new basic_info when only required data is provided" do
      patient = PatientProfile.Factory.insert(:patient)

      params = %{
        title: nil,
        gender: nil,
        first_name: "Ahmed",
        last_name: "Ahmed",
        birth_date: nil,
        email: "ahmedahmed@ahmed.com"
      }

      assert {:ok, %BasicInfo{first_name: "Ahmed"} = basic_info} =
               BasicInfo.update(params, patient.id)

      Enum.each(params, fn {key, value} ->
        assert Map.get(basic_info, key) == value
      end)
    end

    test "updates basic_info when it exists" do
      patient = PatientProfile.Factory.insert(:patient)

      _basic_info =
        PatientProfile.Factory.insert(:basic_info, patient_id: patient.id, first_name: "Ahmed")

      params = %{first_name: "Muhhamad"}

      assert {:ok, %BasicInfo{first_name: "Muhhamad"}} = BasicInfo.update(params, patient.id)
    end

    test "returns validation errors" do
      patient = PatientProfile.Factory.insert(:patient)
      _basic_info = PatientProfile.Factory.insert(:basic_info, patient_id: patient.id)
      params = %{first_name: ""}

      assert {:error, %Ecto.Changeset{}} = BasicInfo.update(params, patient.id)
    end
  end
end
