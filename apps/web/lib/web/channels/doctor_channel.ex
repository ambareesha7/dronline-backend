defmodule Web.DoctorChannel do
  use Web, :channel
  import Mockery.Macro

  alias Proto.Channels.SocketMessage.ChannelPayload

  @topics ["external", "doctor"]

  intercept([
    "call_established",
    "active_package_update",
    "doctor_pending_visits_update",
    "doctor_category_invitations_update"
  ])

  defmacrop calls do
    quote do: mockable(Calls, by: CallsMock)
  end

  def join(topic, _payload, socket) when topic in @topics do
    payload = ChannelPayload.JoinedChannel.new()

    case socket.assigns.type do
      :EXTERNAL ->
        send(self(), :after_join)
        {:ok, %{proto: payload}, socket}

      _ ->
        {:error, %{}}
    end
  end

  def handle_info(:after_join, socket) do
    {:ok, _ref} =
      Web.Presence.track(socket, "doctor_presence", socket.assigns.current_specialist_id)

    {:noreply, socket}
  end

  def handle_in("ping", payload, socket) do
    push(socket, "pong", %{proto: payload})

    {:reply, :ok, socket}
  end

  def handle_in("accept_doctor_category_invitation", payload, socket) do
    cmd = %Calls.DoctorCategoryInvitations.Commands.AcceptInvitation{
      doctor_id: socket.assigns.current_specialist_id,
      category_id: payload.category_id,
      call_id: payload.call_id
    }

    cmd
    |> calls().accept_doctor_category_invitation()
    |> Web.ChannelsHelper.socket_response_for_result(socket)
  end

  @single_doctor_events ["call_established", "doctor_pending_visits_update"]
  def handle_out(event, payload, socket) when event in @single_doctor_events do
    doctor_id = payload.doctor_id

    if socket.assigns.current_specialist_id == doctor_id do
      push(socket, event, payload)
    end

    {:noreply, socket}
  end

  @single_external_events ["active_package_update"]
  def handle_out(event, payload, socket) when event in @single_external_events do
    external_id = payload.external_id
    current_specialist_id = socket.assigns.current_specialist_id

    if socket.assigns.type == :EXTERNAL && current_specialist_id == external_id do
      push(socket, event, payload)
    end

    {:noreply, socket}
  end

  def handle_out("doctor_category_invitations_update", %{proto: payload}, socket) do
    category_id = payload.category_id
    specialist_id = socket.assigns.current_specialist_id

    {:ok, invitations} = Calls.fetch_doctor_category_invitations(specialist_id, category_id)

    specialist_ids = Enum.map(invitations, & &1.invited_by_specialist_id)
    specialists_generic_data = Web.SpecialistGenericData.get_by_ids(specialist_ids)

    specialists_generic_data_map =
      Map.new(specialists_generic_data, fn specialist_generic_data ->
        {specialist_generic_data.specialist.id, specialist_generic_data}
      end)

    invitations =
      Enum.map(invitations, fn invitation ->
        %{invited_by_specialist_id: specialist_id} = invitation

        %{
          invited_by: specialists_generic_data_map[specialist_id],
          call_id: invitation.call_id,
          patient_id: invitation.patient_id,
          record_id: invitation.record_id,
          sent_at: invitation.inserted_at
        }
      end)

    proto = Web.View.Calls.render_doctor_category_invitations(category_id, invitations)
    push(socket, "doctor_category_invitations_update", %{proto: proto})

    {:noreply, socket}
  end
end
