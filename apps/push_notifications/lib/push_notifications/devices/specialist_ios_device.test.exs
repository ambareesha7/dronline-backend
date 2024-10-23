defmodule PushNotifications.Devices.SpecialistIOSDeviceTest do
  use Postgres.DataCase, async: true

  alias PushNotifications.Devices.SpecialistIOSDevice

  describe "register/2" do
    test "creates new specialist device" do
      specialist_id = 1

      {:ok, device} = SpecialistIOSDevice.register(specialist_id, "some_token")

      assert device.specialist_id == specialist_id
      assert device.device_token == "some_token"
    end

    test "allows specialist to have multiple devices" do
      specialist_id = 1

      {:ok, _device1} = SpecialistIOSDevice.register(specialist_id, "some_token1")
      {:ok, _device2} = SpecialistIOSDevice.register(specialist_id, "some_token2")

      assert {:ok, [_, _]} = Repo.fetch_all(SpecialistIOSDevice)
    end

    test "updates specialist_id when existing token is used" do
      specialist1_id = 1
      specialist2_id = 2

      {:ok, _device} = SpecialistIOSDevice.register(specialist1_id, "some_token")
      {:ok, _device} = SpecialistIOSDevice.register(specialist2_id, "some_token")

      {:ok, [device]} = Repo.fetch_all(SpecialistIOSDevice)

      assert device.device_token == "some_token"
      assert device.specialist_id == specialist2_id
    end
  end

  describe "unregister/2" do
    test "removes specialist device" do
      specialist_id = 1
      {:ok, _device} = SpecialistIOSDevice.register(specialist_id, "some_token")

      assert :ok = SpecialistIOSDevice.unregister(specialist_id, "some_token")
      assert {:ok, []} = Repo.fetch_all(SpecialistIOSDevice)
    end

    test "succeeds when given device already doesn't exist" do
      specialist_id = 1
      {:ok, _device} = SpecialistIOSDevice.register(specialist_id, "some_token")

      :ok = SpecialistIOSDevice.unregister(specialist_id, "some_token")
      assert :ok = SpecialistIOSDevice.unregister(specialist_id, "some_token")
    end

    test "doesn't allow to unregister token of another specialist" do
      specialist1_id = 1
      specialist2_id = 2

      {:ok, _device} = SpecialistIOSDevice.register(specialist1_id, "some_token")
      :ok = SpecialistIOSDevice.unregister(specialist2_id, "some_token")

      assert {:ok, [device]} = Repo.fetch_all(SpecialistIOSDevice)
      assert device.specialist_id == specialist1_id
      assert device.device_token == "some_token"
    end
  end
end
