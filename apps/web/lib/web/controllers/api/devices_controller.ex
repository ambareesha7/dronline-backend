defmodule Web.Api.DevicesController do
  use Web, :controller

  action_fallback Web.FallbackController

  @decode Proto.Devices.RegisterDeviceRequest
  def register(conn, _params) do
    patient_id = conn.assigns.current_patient_id
    firebase_token = conn.assigns.protobuf.firebase_token

    {:ok, _device} = PushNotifications.register_patient_device(patient_id, firebase_token)

    conn |> send_resp(200, "")
  end

  @decode Proto.Devices.RegisterIOSDeviceRequest
  def register_ios(conn, _params) do
    patient_id = conn.assigns.current_patient_id
    device_token = conn.assigns.protobuf.device_token

    {:ok, _device} = PushNotifications.register_patient_ios_device(patient_id, device_token)

    conn |> send_resp(200, "")
  end

  @decode Proto.Devices.UnregisterDeviceRequest
  def unregister(conn, _params) do
    patient_id = conn.assigns.current_patient_id
    firebase_token = conn.assigns.protobuf.firebase_token

    :ok = PushNotifications.unregister_patient_device(patient_id, firebase_token)

    conn |> send_resp(200, "")
  end

  @decode Proto.Devices.UnregisterIOSDeviceRequest
  def unregister_ios(conn, _params) do
    patient_id = conn.assigns.current_patient_id
    device_token = conn.assigns.protobuf.device_token

    :ok = PushNotifications.unregister_patient_ios_device(patient_id, device_token)

    conn |> send_resp(200, "")
  end
end
