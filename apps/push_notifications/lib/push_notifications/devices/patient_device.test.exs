defmodule PushNotifications.Devices.PatientDeviceTest do
  use Postgres.DataCase, async: true

  alias PushNotifications.Devices.PatientDevice

  describe "register/2" do
    test "creates new patient device" do
      patient_id = 1

      {:ok, device} = PatientDevice.register(patient_id, "some_token")

      assert device.patient_id == patient_id
      assert device.firebase_token == "some_token"
    end

    test "allows patient to have multiple devices" do
      patient_id = 1

      {:ok, _device1} = PatientDevice.register(patient_id, "some_token1")
      {:ok, _device2} = PatientDevice.register(patient_id, "some_token2")

      assert {:ok, [_, _]} = Repo.fetch_all(PatientDevice)
    end

    test "updates patient_id when existing token is used" do
      patient1_id = 1
      patient2_id = 2

      {:ok, _device} = PatientDevice.register(patient1_id, "some_token")
      {:ok, _device} = PatientDevice.register(patient2_id, "some_token")

      {:ok, [device]} = Repo.fetch_all(PatientDevice)

      assert device.firebase_token == "some_token"
      assert device.patient_id == patient2_id
    end
  end

  describe "unregister/2" do
    test "removes patient device" do
      patient_id = 1
      {:ok, _device} = PatientDevice.register(patient_id, "some_token")

      assert :ok = PatientDevice.unregister(patient_id, "some_token")
      assert {:ok, []} = Repo.fetch_all(PatientDevice)
    end

    test "succeeds when given device already doesn't exist" do
      patient_id = 1
      {:ok, _device} = PatientDevice.register(patient_id, "some_token")

      :ok = PatientDevice.unregister(patient_id, "some_token")
      assert :ok = PatientDevice.unregister(patient_id, "some_token")
    end

    test "doesn't allow to unregister token of another patient" do
      patient1_id = 1
      patient2_id = 2

      {:ok, _device} = PatientDevice.register(patient1_id, "some_token")
      :ok = PatientDevice.unregister(patient2_id, "some_token")

      assert {:ok, [device]} = Repo.fetch_all(PatientDevice)
      assert device.patient_id == patient1_id
      assert device.firebase_token == "some_token"
    end
  end

  describe "all_tokens_for_patient_id/1" do
    test "returns all tokens" do
    end
  end
end
