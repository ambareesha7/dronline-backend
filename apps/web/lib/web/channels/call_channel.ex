defmodule Web.CallChannel do
  use Web, :channel

  require Logger

  alias Calls.Call
  alias Proto.Channels.SocketMessage.ChannelPayload

  def join("call:" <> call_id, _payload, socket) do
    payload = ChannelPayload.JoinedChannel.new()

    case Call.join(call_id, self()) do
      :ok ->
        new_socket = assign(socket, :call_id, call_id)

        {:ok, %{proto: payload}, new_socket}

      _ ->
        {:error, %{}}
    end
  end

  def handle_in("invite_doctor_category", payload, socket) do
    :ok = Call.invite_specialist(socket.assigns.call_id, payload.category_id)

    cmd = %Calls.DoctorCategoryInvitations.Commands.InviteCategory{
      call_id: socket.assigns.call_id,
      category_id: payload.category_id,
      invited_by_specialist_id: socket.assigns.current_specialist_id,
      patient_id: payload.patient_id,
      record_id: payload.record_id,
      session_id: payload.current_session_id
    }

    cmd |> Calls.invite_doctor_category() |> Web.ChannelsHelper.socket_response_for_result(socket)
  end

  def handle_in("cancel_doctor_category_invitation", payload, socket) do
    cmd = %Calls.DoctorCategoryInvitations.Commands.CancelInvitation{
      call_id: payload.category_id,
      category_id: payload.category_id
    }

    cmd
    |> Calls.cancel_doctor_category_invitation()
    |> Web.ChannelsHelper.socket_response_for_result(socket)
  end

  def handle_in("end_call_for_all", _payload, socket) do
    if can_end_call?(socket) do
      payload = %Proto.Calls.EndCallForAll{}

      # TODO: Close the Opentok session
      _ = broadcast(socket, "call_ended", %{proto: payload})

      {:reply, :ok, socket}
    else
      {:reply, :error, socket}
    end
  end

  # DEPRECATED
  def handle_in("patient_location", payload, socket) do
    handle_in("patient_location_coordinates", payload, socket)
  end

  def handle_in("patient_location_coordinates", payload, socket) do
    :ok = Calls.Call.store_patient_location_coordinates(socket.assigns.call_id, payload)
    {:reply, :ok, socket}
  end

  def handle_in("ping", payload, socket) do
    push(socket, "pong", %{proto: payload})

    {:reply, :ok, socket}
  end

  defp can_end_call?(socket) do
    socket.assigns.type in [:GP, :EXTERNAL]
  end
end
