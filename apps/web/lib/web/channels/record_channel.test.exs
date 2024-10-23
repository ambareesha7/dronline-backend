defmodule Web.RecordChannelTest do
  use Web.ChannelCase, async: true

  alias Web.RecordChannel

  alias Proto.Channels.SocketMessage.ChannelPayload
  defp timeout, do: 5000

  describe "join/3" do
    test "with valid type" do
      socket = socket(Web.Socket, 0, %{current_specialist_id: 0, type: :GP})
      payload = ChannelPayload.JoinedChannel.new()

      assert {:ok, %{proto: ^payload}, _socket} =
               subscribe_and_join(socket, RecordChannel, "record:123")
    end

    test "it's successful for for external doctors if they're connected with the patient" do
      patient = PatientProfile.Factory.insert(:patient)
      specialist = Authentication.Factory.insert(:specialist, type: "EXTERNAL")

      {:ok, record} = EMR.create_manual_patient_record(patient.id, specialist.id)

      EMR.register_interaction_between(specialist.id, patient.id)

      socket = socket(Web.Socket, 0, %{current_specialist_id: specialist.id, type: :EXTERNAL})
      payload = ChannelPayload.JoinedChannel.new()

      assert {:ok, %{proto: ^payload}, _socket} =
               subscribe_and_join(socket, RecordChannel, "record:#{record.id}")
    end

    test "the connection is denied when external doctor had no contact with the patient" do
      patient = PatientProfile.Factory.insert(:patient)
      specialist = Authentication.Factory.insert(:specialist, type: "EXTERNAL")

      {:ok, record} = EMR.create_manual_patient_record(patient.id, specialist.id)

      socket = socket(Web.Socket, 0, %{current_specialist_id: specialist.id, type: :EXTERNAL})

      assert {:error, _} = subscribe_and_join(socket, RecordChannel, "record:#{record.id}")
    end

    test "with invalid type" do
      socket = socket(Web.Socket, 0, %{current_specialist_id: 0, type: :PATIENT})

      assert {:error, %{}} = subscribe_and_join(socket, RecordChannel, "record:123")
    end
  end

  test "PING-PONG temporary events" do
    socket = socket(Web.Socket, 0, %{current_specialist_id: 0, type: :GP})
    {:ok, _join_payload, socket} = subscribe_and_join(socket, RecordChannel, "record:123")

    payload = "ping text"

    ref = push(socket, "ping", payload)
    assert_reply(ref, :ok, _, timeout())
    assert_push("pong", _payload, timeout())
  end
end
