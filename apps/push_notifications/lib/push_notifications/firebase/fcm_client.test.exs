defmodule PushNotifications.Firebase.FcmClientTest do
  use Postgres.DataCase, async: true

  import Mockery

  alias PushNotifications.Devices.PatientDevice
  alias PushNotifications.Devices.SpecialistDevice
  alias PushNotifications.Firebase.FcmClient

  describe "send_notification/2" do
    test "return :ok, if Firebase API returned 200" do
      mock_firebase_api_response({:ok, %Tesla.Env{status: 200, body: ""}})

      assert :ok = FcmClient.send_notification(%{}, "access_token", "device_token")
    end

    test "return :error, remove token from database if Firebase API returned 404" do
      mock_firebase_api_response({:ok, %Tesla.Env{status: 404, body: ""}})

      patient_id = 1
      specialist_id = 1

      {:ok, _device} = PatientDevice.register(patient_id, "patient_device_token_1")
      {:ok, _device} = PatientDevice.register(patient_id, "patient_device_token_2")
      {:ok, _device} = SpecialistDevice.register(specialist_id, "specialist_device_token")

      # Remove Patient token
      assert :error = FcmClient.send_notification(%{}, "access_token", "patient_device_token_1")
      assert [%{firebase_token: "patient_device_token_2"}] = Repo.all(PatientDevice)

      # Remove Specialist token
      assert :error = FcmClient.send_notification(%{}, "access_token", "specialist_device_token")
      assert [] = Repo.all(SpecialistDevice)
    end

    test "return :error, don't remove token from database if Firebase API returned error other than 404" do
      mock_firebase_api_response({:ok, %Tesla.Env{status: 401, body: ""}})

      patient_id = 1

      {:ok, _device1} = PatientDevice.register(patient_id, "patient_device_token")

      assert :error = FcmClient.send_notification(%{}, "access_token", "patient_device_token")
      assert [_] = Repo.all(PatientDevice)
    end
  end

  defp mock_firebase_api_response(response) do
    mock(Tesla, [post: 3], fn _, _, _ -> response end)
  end
end
