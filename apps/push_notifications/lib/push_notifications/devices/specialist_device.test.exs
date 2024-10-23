defmodule PushNotifications.Devices.SpecialistDeviceTest do
  use Postgres.DataCase, async: true

  alias PushNotifications.Devices.SpecialistDevice

  describe "register/2" do
    test "creates new specialist device" do
      specialist_id = 1

      {:ok, device} = SpecialistDevice.register(specialist_id, "some_token")

      assert device.specialist_id == specialist_id
      assert device.firebase_token == "some_token"
    end

    test "allows specialist to have multiple devices" do
      specialist_id = 1

      {:ok, _device1} = SpecialistDevice.register(specialist_id, "some_token1")
      {:ok, _device2} = SpecialistDevice.register(specialist_id, "some_token2")

      assert {:ok, [_, _]} = Repo.fetch_all(SpecialistDevice)
    end

    test "updates specialist_id when existing token is used" do
      specialist1_id = 1
      specialist2_id = 2

      {:ok, _device} = SpecialistDevice.register(specialist1_id, "some_token")
      {:ok, _device} = SpecialistDevice.register(specialist2_id, "some_token")

      {:ok, [device]} = Repo.fetch_all(SpecialistDevice)

      assert device.firebase_token == "some_token"
      assert device.specialist_id == specialist2_id
    end
  end

  describe "unregister/2" do
    test "removes specialist device" do
      specialist_id = 1
      {:ok, _device} = SpecialistDevice.register(specialist_id, "some_token")

      assert :ok = SpecialistDevice.unregister(specialist_id, "some_token")
      assert {:ok, []} = Repo.fetch_all(SpecialistDevice)
    end

    test "succeeds when given device already doesn't exist" do
      specialist_id = 1
      {:ok, _device} = SpecialistDevice.register(specialist_id, "some_token")

      :ok = SpecialistDevice.unregister(specialist_id, "some_token")
      assert :ok = SpecialistDevice.unregister(specialist_id, "some_token")
    end

    test "doesn't allow to unregister token of another specialist" do
      specialist1_id = 1
      specialist2_id = 2

      {:ok, _device} = SpecialistDevice.register(specialist1_id, "some_token")
      :ok = SpecialistDevice.unregister(specialist2_id, "some_token")

      assert {:ok, [device]} = Repo.fetch_all(SpecialistDevice)
      assert device.specialist_id == specialist1_id
      assert device.firebase_token == "some_token"
    end
  end
end
