defmodule Web.NurseChannel do
  use Web, :channel
  import Mockery.Macro

  alias Proto.Channels.SocketMessage.ChannelPayload

  @topic "nurse"

  intercept(["call_established", "dispatched"])

  def join(@topic, _payload, socket) do
    payload = ChannelPayload.JoinedChannel.new()

    case socket.assigns.type do
      :NURSE ->
        {:ok, %{proto: payload}, socket}

      _ ->
        {:error, %{}}
    end
  end

  defmacrop calls do
    quote do: mockable(Calls, by: CallsMock)
  end

  def handle_in("ping", payload, socket) do
    push(socket, "pong", %{proto: payload})

    {:reply, :ok, socket}
  end

  def handle_in("call_gp", payload, socket) do
    cmd = %Calls.PendingNurseToGPCalls.Commands.CallGP{
      nurse_id: socket.assigns.current_specialist_id,
      patient_id: payload.patient_id,
      record_id: payload.record_id
    }

    cmd |> calls().call_gp_as_nurse() |> Web.ChannelsHelper.socket_response_for_result(socket)
  end

  def handle_in("cancel_call_to_gp", _payload, socket) do
    cmd = %Calls.PendingNurseToGPCalls.Commands.CancelCallToGP{
      nurse_id: socket.assigns.current_specialist_id
    }

    cmd
    |> calls().cancel_call_to_gp_as_nurse()
    |> Web.ChannelsHelper.socket_response_for_result(socket)
  end

  @sigle_nurse_events ["call_established", "dispatched"]
  def handle_out(event, payload, socket) when event in @sigle_nurse_events do
    nurse_id = payload.nurse_id

    if socket.assigns.current_specialist_id == nurse_id do
      push(socket, event, payload)
    end

    {:noreply, socket}
  end
end
