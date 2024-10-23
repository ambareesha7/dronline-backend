defmodule Web.ChannelBroadcastWorker do
  use GenServer

  @name :channel_broadcast_worker

  # INTERFACE
  def start_link(_) do
    GenServer.start(__MODULE__, [], name: @name)
  end

  # CALLBACKS
  def init(_) do
    {:ok, []}
  end

  def handle_cast(%{event: "call_established", payload: %{data: _}} = request, state) do
    _ =
      Task.Supervisor.start_child(Web.TaskSupervisor, fn ->
        proto = Web.View.Calls.render_call_established(request.payload.data)

        payload = Map.put(request.payload, :proto, proto)

        Web.Endpoint.broadcast!(request.topic, "call_established", payload)
      end)

    {:noreply, state}
  end

  def handle_cast(%{topic: topic, event: event, payload: payload}, state) do
    args = [topic, event, payload]
    _pid = Task.Supervisor.start_child(Web.TaskSupervisor, Web.Endpoint, :broadcast!, args)

    {:noreply, state}
  end

  def handle_cast(:pending_dispatches_update, state) do
    broadcast("nurse", "pending_dispatches_update", &prepare_pending_dispatches_update_payload/0)

    {:noreply, state}
  end

  def handle_cast(:patients_queue_update, state) do
    broadcast("gp", "patients_queue_update", fn -> %{} end)

    {:noreply, state}
  end

  def handle_cast(:pending_nurse_to_gp_calls_update, state) do
    event = "pending_nurse_to_gp_calls_update"

    broadcast("gp", event, &prepare_pending_nurse_to_gp_calls_update_proto/0)

    {:noreply, state}
  end

  def handle_cast(:pending_visits_update, state) do
    broadcast("gp", "pending_visits_update", fn -> nil end)

    {:noreply, state}
  end

  def handle_cast({:doctor_pending_visits_update, doctor_id}, state) do
    fun = fn -> doctor_pending_visits_update(doctor_id) end

    broadcast("external", "doctor_pending_visits_update", fun, %{doctor_id: doctor_id})

    {:noreply, state}
  end

  def handle_cast({:new_timeline_item, timeline_item}, state) do
    topic = "record:" <> to_string(timeline_item.timeline_id)

    broadcast(topic, "new_timeline_item", fn -> prepare_new_timeline_item_proto(timeline_item) end)

    {:noreply, state}
  end

  def handle_cast({:new_timeline_item_comment, comment, updated_comments_counter}, state) do
    topic = "record:" <> to_string(comment.record_id)
    event = "new_timeline_item_comment"

    broadcast(topic, event, fn ->
      prepare_new_timeline_item_comment_proto(comment, updated_comments_counter)
    end)

    {:noreply, state}
  end

  def handle_cast({:doctor_category_invitations_update, category_id}, state) do
    broadcast("external", "doctor_category_invitations_update", fn ->
      %{category_id: category_id}
    end)

    {:noreply, state}
  end

  defp broadcast(topic, event, payload_fn, intercept_filter \\ %{})

  defp broadcast(topic, event, payload_fn, intercept_filter)
       when topic in ["doctor", "external"] do
    _ =
      Task.Supervisor.start_child(Web.TaskSupervisor, fn ->
        proto = payload_fn.()

        Web.Endpoint.broadcast!("doctor", event, Map.merge(intercept_filter, %{proto: proto}))
        Web.Endpoint.broadcast!("external", event, Map.merge(intercept_filter, %{proto: proto}))
      end)

    :ok
  end

  defp broadcast(topic, event, payload_fn, intercept_filter) do
    _ =
      Task.Supervisor.start_child(Web.TaskSupervisor, fn ->
        proto = payload_fn.()

        Web.Endpoint.broadcast!(topic, event, Map.merge(intercept_filter, %{proto: proto}))
      end)

    :ok
  end

  defp doctor_pending_visits_update(doctor_id) do
    pending_visits = Visits.fetch_pending_visits_for_specialist(doctor_id)

    patient_ids = Enum.map(pending_visits, & &1.patient_id)
    patients_generic_data = Web.PatientGenericData.get_by_ids(patient_ids)

    %Proto.Visits.DoctorPendingVisitsUpdate{
      visits: Enum.map(pending_visits, &Web.View.Visits.render_visit_data_for_specialist/1),
      patients: Enum.map(patients_generic_data, &Web.View.Generics.render_patient/1)
    }
  end

  defp prepare_pending_dispatches_update_payload do
    {:ok, pending_dispatches} = Triage.fetch_pending_dispatches()

    specialist_ids = Enum.map(pending_dispatches, & &1.requester_id)
    specialists_generic_data = Web.SpecialistGenericData.get_by_ids(specialist_ids)

    patient_ids = Enum.map(pending_dispatches, & &1.patient_id)
    patients_generic_data = Web.PatientGenericData.get_by_ids(patient_ids)

    %Proto.Dispatches.PendingDispatchesUpdate{
      dispatches: Enum.map(pending_dispatches, &Web.View.Dispatches.render_dispatch/1),
      specialists: Enum.map(specialists_generic_data, &Web.View.Generics.render_specialist/1),
      patients: Enum.map(patients_generic_data, &Web.View.Generics.render_patient/1)
    }
  end

  # TODO write tests :(
  defp prepare_pending_nurse_to_gp_calls_update_proto do
    {:ok, pending_calls} = Calls.fetch_pending_nurse_to_gp_calls()

    nurse_ids = Enum.map(pending_calls, & &1.nurse_id)
    specialists_generic_data = Web.SpecialistGenericData.get_by_ids(nurse_ids)

    specialists_generic_data_map =
      Map.new(specialists_generic_data, fn specialist_generic_data ->
        {specialist_generic_data.specialist.id, specialist_generic_data}
      end)

    pending_calls =
      Enum.map(pending_calls, fn queue_entry ->
        %{nurse_id: nurse_id, patient_id: patient_id, record_id: record_id} = queue_entry

        %{
          nurse: specialists_generic_data_map[nurse_id],
          patient_id: patient_id,
          record_id: record_id
        }
      end)

    Web.View.Calls.render_pending_nurse_to_gp_calls(pending_calls)
  end

  defp prepare_new_timeline_item_proto(timeline_item) do
    specialists_generic_data =
      timeline_item
      |> EMR.specialist_ids_in_timeline_item()
      |> Web.SpecialistGenericData.get_by_ids()

    Web.View.Timeline.render_new_timeline_item(timeline_item, specialists_generic_data)
  end

  defp prepare_new_timeline_item_comment_proto(timeline_item_comment, updated_comments_counter) do
    specialist_generic_data =
      Web.SpecialistGenericData.get_by_id(timeline_item_comment.commented_by_specialist_id)

    Web.View.EMR.render_new_timeline_item_comment(
      timeline_item_comment,
      updated_comments_counter,
      specialist_generic_data
    )
  end
end
