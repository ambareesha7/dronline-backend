defmodule PushNotifications.Devices.PatientIOSDeviceTest do
  use Postgres.DataCase, async: true

  alias PushNotifications.Devices.PatientIOSDevice

  describe "register/2" do
    test "creates new patient device" do
      patient_id = 1

      {:ok, device} = PatientIOSDevice.register(patient_id, "some_token")

      assert device.patient_id == patient_id
      assert device.device_token == "some_token"
    end

    test "allows patient to have multiple devices" do
      patient_id = 1

      {:ok, _device1} = PatientIOSDevice.register(patient_id, "some_token1")
      {:ok, _device2} = PatientIOSDevice.register(patient_id, "some_token2")

      assert {:ok, [_, _]} = Repo.fetch_all(PatientIOSDevice)
    end

    test "updates patient_id when existing token is used" do
      patient1_id = 1
      patient2_id = 2

      {:ok, _device} = PatientIOSDevice.register(patient1_id, "some_token")
      {:ok, _device} = PatientIOSDevice.register(patient2_id, "some_token")

      {:ok, [device]} = Repo.fetch_all(PatientIOSDevice)

      assert device.device_token == "some_token"
      assert device.patient_id == patient2_id
    end
  end

  describe "unregister/2" do
    test "removes patient device" do
      patient_id = 1
      {:ok, _device} = PatientIOSDevice.register(patient_id, "some_token")

      assert :ok = PatientIOSDevice.unregister(patient_id, "some_token")
      assert {:ok, []} = Repo.fetch_all(PatientIOSDevice)
    end

    test "succeeds when given device already doesn't exist" do
      patient_id = 1
      {:ok, _device} = PatientIOSDevice.register(patient_id, "some_token")

      :ok = PatientIOSDevice.unregister(patient_id, "some_token")
      assert :ok = PatientIOSDevice.unregister(patient_id, "some_token")
    end

    test "doesn't allow to unregister token of another patient" do
      patient1_id = 1
      patient2_id = 2

      {:ok, _device} = PatientIOSDevice.register(patient1_id, "some_token")
      :ok = PatientIOSDevice.unregister(patient2_id, "some_token")

      assert {:ok, [device]} = Repo.fetch_all(PatientIOSDevice)
      assert device.patient_id == patient1_id
      assert device.device_token == "some_token"
    end
  end
end
