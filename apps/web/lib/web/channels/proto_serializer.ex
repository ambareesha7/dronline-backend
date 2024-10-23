defmodule Web.Channels.ProtoSerializer do
  @behaviour Phoenix.Socket.Serializer
  # PROTOCOL 2.0.0

  require Logger

  alias Phoenix.Socket.Message
  alias Phoenix.Socket.Reply

  alias Proto.Channels.SocketMessage

  # FASTLANE BROADCAST
  def fastlane!(%Message{} = broadcast) do
    _ = Logger.info(fn -> "CHANNEL FASTLANE!: " <> inspect(broadcast) end)

    protobuf =
      [
        topic: broadcast.topic,
        event: broadcast.event,
        payload: broadcast.payload |> normalize_message_payload(broadcast.event)
      ]
      |> SocketMessage.new()
      |> SocketMessage.encode()

    {:socket_push, :binary, protobuf}
  end

  # ENCODE MESSAGE
  def encode!(%Message{} = msg) do
    _ = Logger.info(fn -> "CHANNEL ENCODE!: " <> inspect(msg) end)

    protobuf =
      [
        topic: msg.topic,
        event: msg.event,
        payload: msg.payload |> normalize_message_payload(msg.event),
        ref: msg.ref |> to_string(),
        join_ref: msg.join_ref |> to_string()
      ]
      |> SocketMessage.new()
      |> SocketMessage.encode()

    {:socket_push, :binary, protobuf}
  end

  # ENCODE REPLY
  def encode!(%Reply{} = reply) do
    protobuf =
      [
        topic: reply.topic,
        event: "phx_reply",
        payload: reply.payload |> normalize_reply_payload(),
        ref: reply.ref |> to_string(),
        join_ref: reply.join_ref |> to_string(),
        reply_status: reply.status |> to_string()
      ]
      |> SocketMessage.new()
      |> SocketMessage.encode()

    {:socket_push, :binary, protobuf}
  end

  # DECODE MESSAGE
  def decode!(raw, _opts) do
    decoded = SocketMessage.decode(raw)

    %Message{
      topic: decoded.topic,
      event: decoded.event,
      payload: decoded.payload |> denormalize_payload(decoded.event),
      ref: decoded.ref,
      join_ref: decoded.join_ref
    }
  end

  # PRIVATE
  # reply with reason
  defp normalize_reply_payload(%{reason: reason}) do
    SocketMessage.ChannelPayload.new(message: {:phx_reply, reason})
  end

  # reply without payload
  defp normalize_reply_payload(_payload), do: nil

  # event without payload
  defp normalize_message_payload(payload, _event) when map_size(payload) == 0, do: nil

  # event with protobuf
  defp normalize_message_payload(%{proto: payload}, event) do
    SocketMessage.ChannelPayload.new(message: {String.to_existing_atom(event), payload})
  end

  # event without payload
  defp denormalize_payload(nil, _event), do: nil
  defp denormalize_payload(%SocketMessage.ChannelPayload{message: nil}, _event), do: nil

  # TODO remove when new protobuf will be integrated
  defp denormalize_payload(payload, "patient_location") do
    denormalize_payload(payload, "patient_location_coordinates")
  end

  # event with protobuf
  defp denormalize_payload(payload, event) do
    event = String.to_existing_atom(event)
    %SocketMessage.ChannelPayload{message: {^event, payload_body}} = payload

    payload_body
  end
end
