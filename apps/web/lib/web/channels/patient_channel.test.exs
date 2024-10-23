defmodule Web.PatientChannelTest do
  use Web.ChannelCase, async: false

  alias Web.PatientChannel

  alias Proto.Channels.SocketMessage.ChannelPayload

  @topic "patient"

  describe "join/3" do
    test "with valid type" do
      socket = socket(Web.Socket, 0, %{current_patient_id: 0, type: :PATIENT, device_id: "foo"})
      payload = ChannelPayload.JoinedChannel.new()

      assert {:ok, %{proto: ^payload}, _socket} =
               subscribe_and_join(socket, PatientChannel, @topic)

      :ok = close(socket)
    end

    test "with invalid type" do
      socket = socket(Web.Socket, 0, %{current_patient_id: 0, type: :GP, device_id: "foo"})

      assert {:error, %{}} = subscribe_and_join(socket, PatientChannel, @topic)

      :ok = close(socket)
      # assert_reply ref, :ok
    end
  end

  test "PING-PONG temporary events" do
    socket = socket(Web.Socket, 0, %{current_patient_id: 0, type: :PATIENT, device_id: "foo"})
    {:ok, _join_payload, socket} = subscribe_and_join(socket, PatientChannel, @topic)

    payload = "ping text"

    ref = push(socket, "ping", payload)
    assert_reply(ref, :ok)
    assert_push("pong", _payload)
  end
end
