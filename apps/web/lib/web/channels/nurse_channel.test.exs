defmodule Web.NurseChannelTest do
  use Web.ChannelCase, async: true

  alias Web.NurseChannel

  alias Proto.Channels.SocketMessage.ChannelPayload
  defp timeout, do: 5000

  describe "join/3" do
    test "with valid type" do
      socket = socket(Web.Socket, 0, %{current_specialist_id: 0, type: :NURSE})
      payload = ChannelPayload.JoinedChannel.new()

      assert {:ok, %{proto: ^payload}, _socket} =
               subscribe_and_join(socket, NurseChannel, "nurse")
    end

    test "with invalid type" do
      socket = socket(Web.Socket, 0, %{current_specialist_id: 0, type: :GP})

      assert {:error, %{}} = subscribe_and_join(socket, NurseChannel, "nurse")
    end
  end

  test "PING-PONG temporary events" do
    socket = socket(Web.Socket, 0, %{current_specialist_id: 0, type: :NURSE})
    {:ok, _join_payload, socket} = subscribe_and_join(socket, NurseChannel, "nurse")

    payload = "ping text"

    ref = push(socket, "ping", payload)
    assert_reply(ref, :ok, _, timeout())
    assert_push("pong", _payload, timeout())
  end

  describe "handle_in" do
    test "call_gp" do
      nurse = Authentication.Factory.insert(:specialist, type: "NURSE")

      socket = socket(Web.Socket, 0, %{current_specialist_id: nurse.id, type: :NURSE})
      {:ok, _join_payload, socket} = subscribe_and_join(socket, NurseChannel, "nurse")

      payload = %Proto.Calls.CallGP{patient_id: 0, record_id: 0}

      ref = push(socket, "call_gp", payload)
      assert_reply(ref, :ok, _, timeout())
    end

    test "cancel_call_to_gp" do
      nurse = Authentication.Factory.insert(:specialist, type: "NURSE")

      socket = socket(Web.Socket, 0, %{current_specialist_id: nurse.id, type: :NURSE})
      {:ok, _join_payload, socket} = subscribe_and_join(socket, NurseChannel, "nurse")

      payload = %Proto.Calls.CancelCallToGP{}

      ref = push(socket, "cancel_call_to_gp", payload)
      assert_reply(ref, :ok, _, timeout())
    end
  end
end
