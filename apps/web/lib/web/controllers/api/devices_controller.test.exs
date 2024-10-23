defmodule Web.Api.DevicesControllerTest do
  use Web.ConnCase, async: true

  alias Proto.Devices.RegisterDeviceRequest
  alias Proto.Devices.RegisterIOSDeviceRequest
  alias Proto.Devices.UnregisterDeviceRequest
  alias Proto.Devices.UnregisterIOSDeviceRequest

  setup [:proto_content, :authenticate_patient]

  test "PUT register", %{conn: conn, current_patient: current_patient} do
    proto = %RegisterDeviceRequest{firebase_token: "token"} |> RegisterDeviceRequest.encode()

    conn = put(conn, devices_path(conn, :register), proto)
    assert conn.status == 200

    {:ok, [device]} = Postgres.Repo.fetch_all(PushNotifications.Devices.PatientDevice)

    assert device.patient_id == current_patient.id
    assert device.firebase_token == "token"
  end

  test "PUT register_ios", %{conn: conn, current_patient: current_patient} do
    proto = %RegisterIOSDeviceRequest{device_token: "token"} |> RegisterIOSDeviceRequest.encode()

    conn = put(conn, devices_path(conn, :register_ios), proto)
    assert conn.status == 200

    {:ok, [device]} = Postgres.Repo.fetch_all(PushNotifications.Devices.PatientIOSDevice)

    assert device.patient_id == current_patient.id
    assert device.device_token == "token"
  end

  test "PUT unregister", %{conn: conn} do
    proto = %UnregisterDeviceRequest{firebase_token: "token"} |> UnregisterDeviceRequest.encode()

    conn = put(conn, devices_path(conn, :unregister), proto)
    assert conn.status == 200
  end

  test "PUT unregister_ios", %{conn: conn} do
    proto =
      %UnregisterIOSDeviceRequest{device_token: "token"} |> UnregisterIOSDeviceRequest.encode()

    conn = put(conn, devices_path(conn, :unregister_ios), proto)
    assert conn.status == 200
  end
end
