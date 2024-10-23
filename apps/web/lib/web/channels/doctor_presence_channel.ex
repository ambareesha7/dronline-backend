defmodule Web.DoctorPresenceChannel do
  use Web, :channel

  alias Proto.Channels.SocketMessage.ChannelPayload

  @topic "doctor_presence"

  def join(@topic, _payload, socket) do
    payload = ChannelPayload.JoinedChannel.new()

    send(self(), :after_join)
    {:ok, %{proto: payload}, socket}
  end

  def handle_info(:after_join, socket) do
    presence_list = Web.Presence.list(@topic)

    payload = %{
      proto: Web.Views.Presence.render_presence_state(presence_list)
    }

    push(socket, "presence_state", payload)

    {:noreply, socket}
  end

  def handle_in(_event, _payload, socket) do
    {:noreply, socket}
  end

  def handle_out(_event, _msg, socket) do
    {:noreply, socket}
  end
end
