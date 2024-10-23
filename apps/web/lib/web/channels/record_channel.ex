defmodule Web.RecordChannel do
  use Web, :channel

  alias Proto.Channels.SocketMessage.ChannelPayload

  def join("record:" <> record_id, _payload, socket) do
    payload = ChannelPayload.JoinedChannel.new()
    record_id = String.to_integer(record_id)

    case socket.assigns.type do
      :PATIENT ->
        {:error, %{}}

      :EXTERNAL ->
        if EMR.specialist_patient_connected?(
             socket.assigns.current_specialist_id,
             record_id,
             true
           ) do
          {:ok, %{proto: payload}, socket}
        else
          {:error, %{}}
        end

      _type ->
        {:ok, %{proto: payload}, socket}
    end
  end

  def handle_in("ping", payload, socket) do
    push(socket, "pong", %{proto: payload})

    {:reply, :ok, socket}
  end
end
