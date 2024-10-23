defmodule Web.CallChannelTest do
  use Web.ChannelCase, async: true

  alias Web.CallChannel

  alias Proto.Channels.SocketMessage.ChannelPayload

  describe "join/3" do
    test "gp can join a channel" do
      socket = socket(Web.Socket, 0, %{current_specialist_id: 0, type: :GP})
      payload = ChannelPayload.JoinedChannel.new()

      call_id = Calls.Call.start()

      assert {:ok, %{proto: ^payload}, _socket} =
               subscribe_and_join(socket, CallChannel, "call:#{call_id}")
    end
  end

  describe "ending call for all" do
    test "after sending the end_call_for_all message, the server broadcasts call_ended message" do
      socket = socket(Web.Socket, 0, %{current_specialist_id: 0, type: :GP})

      call_id = Calls.Call.start()

      {:ok, _resp, socket} = subscribe_and_join(socket, CallChannel, "call:#{call_id}")

      payload = %Proto.Calls.EndCallForAll{}
      push(socket, "end_call_for_all", payload)

      assert_broadcast("call_ended", _)
    end

    test "patients should not be able to end the call" do
      socket = socket(Web.Socket, 0, %{current_patient_id: 0, type: :PATIENT})

      call_id = Calls.Call.start()

      {:ok, _resp, socket} = subscribe_and_join(socket, CallChannel, "call:#{call_id}")

      payload = %Proto.Calls.EndCallForAll{}
      ref = push(socket, "end_call_for_all", payload)
      assert_reply(ref, :error)
    end
  end

  test "patient's location can be stored inside the Call process" do
    socket = socket(Web.Socket, 0, %{current_patient_id: 0, type: :PATIENT})
    call_id = Calls.Call.start()
    {:ok, _resp, socket} = subscribe_and_join(socket, CallChannel, "call:#{call_id}")

    payload = %Proto.Generics.Coordinates{lon: 1.0, lat: 2.5}
    ref = push(socket, "patient_location", payload)

    assert_reply(ref, :ok)

    assert %{lon: 1.0, lat: 2.5} = Calls.Call.get_patient_location_coordinates(call_id)
  end
end
