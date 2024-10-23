defmodule Triage.Commands do
  use Postgres.Service

  import Mockery.Macro

  alias EMR.PatientRecords.Autoclose.Saga, as: AutocloseSaga

  @spec request_dispatch_to_patient(Triage.Commands.RequestDispatchToPatient.t()) ::
          {:ok, %Triage.PendingDispatch{}} | {:error, term}
  def request_dispatch_to_patient(%Triage.Commands.RequestDispatchToPatient{} = cmd) do
    result =
      Repo.transaction(fn ->
        with {:ok, _waiting_patient} <- add_patient_to_waiting_list(cmd),
             {:ok, pending_dispatch} <- create_pending_dispatch(cmd) do
          pending_dispatch
        else
          {:error, reason} ->
            Repo.rollback(reason)
        end
      end)

    :ok = create_timeline_item(result)
    :ok = broadcast_update_on_success(result)
    :ok = AutocloseSaga.register_dispatch_request(cmd.patient_id, cmd.record_id, cmd.request_id)

    result
  end

  defmacrop pending_dispatch do
    quote do: mockable(Triage.PendingDispatch)
  end

  @spec take_pending_dispatch(Triage.Commands.TakePendingDispatch.t()) ::
          {:ok, %Triage.OngoingDispatch{}} | {:error, term}
  def take_pending_dispatch(%Triage.Commands.TakePendingDispatch{} = cmd) do
    result =
      Repo.transaction(fn ->
        with {:ok, pending_dispatch} <- pending_dispatch().fetch_by_request_id(cmd.request_id),
             {:ok, ongoing_dispatch} <- create_ongoing_dispatch(pending_dispatch, cmd),
             :ok <- remove_pending_dispatch(cmd.request_id) do
          ongoing_dispatch
        else
          {:error, reason} ->
            Repo.rollback(reason)
        end
      end)

    :ok = broadcast_update_on_success(result)
    :ok = create_medical_pending_summary(result)
    :ok = send_notification_to_patient_on_success(result)

    result
  end

  @spec end_dispatch(Triage.Commands.EndDispatch.t()) ::
          {:ok, %Triage.EndedDispatch{}} | {:error, term}
  def end_dispatch(%Triage.Commands.EndDispatch{} = cmd) do
    result =
      Repo.transaction(fn ->
        with {:ok, ongoing_dispatch} <-
               Triage.OngoingDispatch.fetch_by_request_id(cmd.request_id),
             {:allowed?, true} <- {:allowed?, ongoing_dispatch.nurse_id == cmd.nurse_id},
             {:ok, ended_dispatch} <- create_ended_dispatch(ongoing_dispatch),
             :ok <- remove_ongoing_dispatch(cmd.request_id),
             :ok <- remove_patient_from_waiting_list(cmd.request_id) do
          ended_dispatch
        else
          {:error, reason} ->
            Repo.rollback(reason)

          {:allowed?, false} ->
            Repo.rollback(:forbidden)
        end
      end)

    :ok = inform_record_autoclose_saga(result, cmd.request_id)

    result
  end

  defp add_patient_to_waiting_list(cmd) do
    params = Map.from_struct(cmd)

    %Triage.PatientWaitingForDispatch{}
    |> Triage.PatientWaitingForDispatch.changeset(params)
    |> Repo.insert()
  end

  defp create_pending_dispatch(cmd) do
    params = cmd |> Map.from_struct() |> Map.put(:requested_at, DateTime.utc_now())

    %Triage.PendingDispatch{}
    |> Triage.PendingDispatch.changeset(params)
    |> Repo.insert()
  end

  defp create_ongoing_dispatch(%Triage.PendingDispatch{} = pending_dispatch, cmd) do
    params =
      pending_dispatch
      |> Map.from_struct()
      |> Map.update!(:patient_location_address, &Map.from_struct/1)
      |> Map.put(:nurse_id, cmd.nurse_id)
      |> Map.put(:taken_at, DateTime.utc_now())

    %Triage.OngoingDispatch{}
    |> Triage.OngoingDispatch.changeset(params)
    |> Repo.insert()
  end

  defp remove_pending_dispatch(request_id) do
    _ = Triage.PendingDispatch |> where(request_id: ^request_id) |> Repo.delete_all()

    :ok
  end

  defp create_ended_dispatch(%Triage.OngoingDispatch{} = ongoing_dispatch) do
    params =
      ongoing_dispatch
      |> Map.from_struct()
      |> Map.update!(:patient_location_address, &Map.from_struct/1)
      |> Map.put(:ended_at, DateTime.utc_now())

    %Triage.EndedDispatch{}
    |> Triage.EndedDispatch.changeset(params)
    |> Repo.insert()
  end

  defp remove_ongoing_dispatch(request_id) do
    _ = Triage.OngoingDispatch |> where(request_id: ^request_id) |> Repo.delete_all()

    :ok
  end

  defp remove_patient_from_waiting_list(request_id) do
    _ = Triage.PatientWaitingForDispatch |> where(request_id: ^request_id) |> Repo.delete_all()

    :ok
  end

  defmacrop channel_broadcast do
    quote do: mockable(Triage.ChannelBroadcast, by: Triage.ChannelBroadcastMock)
  end

  defmacrop notification do
    quote do: mockable(PushNotifications.Message)
  end

  defp broadcast_update_on_success({:ok, _}) do
    channel_broadcast().broadcast(:pending_dispatches_update)

    :ok
  end

  defp broadcast_update_on_success({:error, _}) do
    :ok
  end

  defp create_timeline_item({:ok, %Triage.PendingDispatch{} = dispatch}) do
    cmd = %EMR.PatientRecords.Timeline.Commands.CreateDispatchRequestItem{
      patient_id: dispatch.patient_id,
      patient_location_address: dispatch.patient_location_address,
      record_id: dispatch.record_id,
      request_id: dispatch.request_id,
      requester_id: dispatch.requester_id
    }

    _ = EMR.create_dispatch_request_item(cmd)

    :ok
  end

  defp create_timeline_item(_) do
    :ok
  end

  defp create_medical_pending_summary({:ok, %Triage.OngoingDispatch{} = dispatch}) do
    {:ok, :created} =
      EMR.PatientRecords.MedicalSummary.PendingSummary.create(
        dispatch.patient_id,
        dispatch.record_id,
        dispatch.nurse_id
      )

    :ok
  end

  defp create_medical_pending_summary(_) do
    :ok
  end

  defp send_notification_to_patient_on_success({:ok, %Triage.OngoingDispatch{} = dispatch}) do
    notification().send(%PushNotifications.Message.TriageUnitDispatched{
      record_id: dispatch.record_id,
      send_to_patient_id: PatientProfilesManagement.who_should_be_notified(dispatch.patient_id)
    })
  end

  defp send_notification_to_patient_on_success(_) do
    :ok
  end

  defp inform_record_autoclose_saga({:ok, ended_dispatch} = _result, request_id) do
    %{patient_id: patient_id, record_id: record_id} = ended_dispatch

    :ok = AutocloseSaga.register_dispatch_end(patient_id, record_id, request_id)
  end

  defp inform_record_autoclose_saga(_result, _request_id) do
    :ok
  end
end
