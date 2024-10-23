defmodule Web.PanelApi.DevicesControllerTest do
  use Web.ConnCase, async: true

  alias Proto.Devices.RegisterDeviceRequest
  alias Proto.Devices.RegisterIOSDeviceRequest
  alias Proto.Devices.UnregisterDeviceRequest
  alias Proto.Devices.UnregisterIOSDeviceRequest

  setup [:proto_content, :authenticate_gp]

  test "PUT register", %{conn: conn, current_gp: current_gp} do
    proto = %RegisterDeviceRequest{firebase_token: "token"} |> RegisterDeviceRequest.encode()

    conn = put(conn, panel_devices_path(conn, :register), proto)
    assert conn.status == 200

    {:ok, [device]} = Postgres.Repo.fetch_all(PushNotifications.Devices.SpecialistDevice)

    assert device.specialist_id == current_gp.id
    assert device.firebase_token == "token"
  end

  test "PUT register_ios", %{conn: conn, current_gp: current_gp} do
    proto = %RegisterIOSDeviceRequest{device_token: "token"} |> RegisterIOSDeviceRequest.encode()

    conn = put(conn, panel_devices_path(conn, :register_ios), proto)
    assert conn.status == 200

    {:ok, [device]} = Postgres.Repo.fetch_all(PushNotifications.Devices.SpecialistIOSDevice)

    assert device.specialist_id == current_gp.id
    assert device.device_token == "token"
  end

  test "PUT unregister", %{conn: conn} do
    proto = %UnregisterDeviceRequest{firebase_token: "token"} |> UnregisterDeviceRequest.encode()

    conn = put(conn, panel_devices_path(conn, :unregister), proto)
    assert conn.status == 200
  end

  test "PUT unregister_ios", %{conn: conn} do
    proto =
      %UnregisterIOSDeviceRequest{device_token: "token"} |> UnregisterIOSDeviceRequest.encode()

    conn = put(conn, panel_devices_path(conn, :unregister), proto)
    assert conn.status == 200
  end
end
