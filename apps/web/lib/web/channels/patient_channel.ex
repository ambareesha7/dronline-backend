defmodule Web.PatientChannel do
  use Web, :channel

  require Logger

  alias Proto.Channels.SocketMessage.ChannelPayload

  @topic "patient"

  intercept(["call_established", "presence_diff"])

  def join(@topic, _payload, socket) do
    payload = ChannelPayload.JoinedChannel.new()

    send(self(), :after_join)

    case socket.assigns.type do
      :PATIENT ->
        {:ok, %{proto: payload}, socket}

      _ ->
        {:error, %{}}
    end
  end

  def handle_info(:after_join, socket) do
    {:noreply, socket}
  end

  def handle_in("ping", payload, socket) do
    push(socket, "pong", %{proto: payload})

    {:reply, :ok, socket}
  end

  def handle_in("join_queue", payload, socket) do
    device_id = socket.assigns.device_id
    patient_id = socket.assigns.current_patient_id

    cmd = %{
      # Protobuf set default value https://protobuf.dev/programming-guides/proto3/#default
      # record_id cannot ever be 0, because it's alaways positive integer in database,
      # if it is 0 it means it's default value, as it was not sent, and we assign it proper nil.
      record_id: if(payload.record_id == 0, do: nil, else: payload.record_id),
      patient_id: patient_id,
      device_id: device_id,
      payment_params: payload.payment_params
    }

    socket_response =
      cmd
      |> UrgentCare.PatientsQueue.add_to_queue()
      |> case do
        %UrgentCare.PatientsQueue.Schema{} -> :ok
        error -> error
      end
      |> Web.ChannelsHelper.socket_response_for_result(socket)

    Calls.ChannelBroadcast.broadcast(:patients_queue_update)

    socket_response
  end

  def handle_in("leave_queue", _payload, socket) do
    patient_id = socket.assigns.current_patient_id

    with :ok <- UrgentCare.PatientsQueue.remove_from_queue(patient_id) do
      Web.ChannelsHelper.socket_response_for_result(:ok, socket)
    end
  end

  def handle_out("presence_diff", _message, socket) do
    {:noreply, socket}
  end

  @sigle_patient_events ["call_established"]
  def handle_out(event, payload, socket) when event in @sigle_patient_events do
    patient_id = payload.patient_id

    if socket.assigns.current_patient_id == patient_id do
      push(socket, event, payload)
    end

    {:noreply, socket}
  end

  def terminate(
        _reason,
        %Phoenix.Socket{joined: true} = socket
      ) do
    UrgentCare.PatientsQueue.remove_from_queue(socket.assigns.current_patient_id)
  end

  def terminate(_reason, _socket) do
    :ok
  end
end
