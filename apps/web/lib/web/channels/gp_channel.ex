defmodule Web.GPChannel do
  use Web, :channel

  import Mockery.Macro

  alias Proto.Channels.SocketMessage.ChannelPayload

  @topic "gp"

  intercept([
    "call_established",
    "call_failure",
    "patients_queue_update",
    "pending_visits_update"
  ])

  def join(@topic, _payload, socket) do
    payload = ChannelPayload.JoinedChannel.new()

    specialist_id = socket.assigns.current_specialist_id

    if socket.assigns.type == :GP or Teams.is_admin?(specialist_id) do
      {:ok, %{proto: payload}, socket}
    else
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

  def handle_in("start_call", payload, socket) do
    %{
      patient_id: payload.caller_id,
      gp_id: socket.assigns.current_specialist_id,
      call_id: Calls.Call.start()
    }
    |> UrgentCare.PatientsQueue.establish_call()
    |> case do
      {:ok, true} -> :ok
      error -> error
    end
    |> Web.ChannelsHelper.socket_response_for_result(socket)
  end

  def handle_in("answer_call_from_nurse", payload, socket) do
    cmd = %Calls.PendingNurseToGPCalls.Commands.AnswerCallFromNurse{
      gp_id: socket.assigns.current_specialist_id,
      nurse_id: payload.nurse_id
    }

    cmd
    |> calls().answer_call_from_nurse_as_gp()
    |> Web.ChannelsHelper.socket_response_for_result(socket)
  end

  def handle_out("patients_queue_update", _payload, socket) do
    # In general, querying the DB inside `handle_out` is not a good idea, since
    # it's executed for every connected client and it could really slow down
    # the DB.
    # But in this case, the risk is smaller because there are not so many GPs
    # and the development cost of doing that properly* is higher.
    #
    # * By properly, I mean broadcasting only to the GPs whose queue changed.

    gp_id = socket.assigns.current_specialist_id

    patients_queue = Web.PatientsQueueData.get_by_gp_id(gp_id)

    payload = Web.View.Calls.render_patients_queue_v2(patients_queue)
    push(socket, "patients_queue_update", %{proto: payload})

    {:noreply, socket}
  end

  def handle_out("pending_visits_update", _payload, socket) do
    gp_id = socket.assigns.current_specialist_id

    pending_visits = Visits.fetch_pending_visits(gp_id)

    specialist_ids = Enum.map(pending_visits, & &1.specialist_id)
    specialists_generic_data = Web.SpecialistGenericData.get_by_ids(specialist_ids)

    patient_ids = Enum.map(pending_visits, & &1.patient_id)
    patients_generic_data = Web.PatientGenericData.get_by_ids(patient_ids)

    payload = %Proto.Visits.PendingVisitsUpdate{
      visits: Enum.map(pending_visits, &Web.View.Visits.render_visit_data_for_specialist/1),
      specialists: Enum.map(specialists_generic_data, &Web.View.Generics.render_specialist/1),
      patients: Enum.map(patients_generic_data, &Web.View.Generics.render_patient/1)
    }

    push(socket, "patients_queue_update", %{proto: payload})

    {:noreply, socket}
  end

  @sigle_gp_events ["call_established", "call_failure"]
  def handle_out(event, payload, socket) when event in @sigle_gp_events do
    gp_id = payload.gp_id

    if socket.assigns.current_specialist_id == gp_id do
      push(socket, event, payload)
    end

    {:noreply, socket}
  end
end
