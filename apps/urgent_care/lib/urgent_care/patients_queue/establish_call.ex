defmodule UrgentCare.PatientsQueue.EstablishCall do
  alias Ecto.Multi

  def call(args) do
    %{record_id: record_id} = UrgentCare.PatientsQueue.Schema.fetch_by_patient_id(args.patient_id)

    Multi.new()
    |> Multi.run(:params, fn _, _ -> {:ok, Map.put(args, :record_id, record_id)} end)
    |> Multi.run(:emr_set_with_whom_value_for_record, &emr_set_with_whom_value_for_record/2)
    |> Multi.run(:handle_call_established, &handle_call_established/2)
    |> Multi.run(:add_emr_connection, &add_emr_connection/2)
    |> Multi.run(:update_urgent_care_request, &update_urgent_care_request/2)
    |> Multi.run(:remove_from_queue, &remove_from_queue/2)
    |> Postgres.Repo.transaction()
    |> case do
      {:ok, _multi} ->
        {:ok, true}

      {:error, _failed_operation, reason, _changes_so_far} ->
        {:error, reason}
    end
  end

  defp emr_set_with_whom_value_for_record(_repo, %{params: params}) do
    :ok = EMR.set_with_whom_value_for_record(params.patient_id, params.record_id, params.gp_id)
    {:ok, true}
  end

  defp handle_call_established(_repo, %{params: params}) do
    Calls.Connections.CallEstablished.handle_call_established(params)
    {:ok, true}
  end

  defp add_emr_connection(_repo, %{params: params}) do
    EMR.SpecialistPatientConnections.SpecialistPatientConnection.create(
      params.gp_id,
      params.patient_id
    )
  end

  defp update_urgent_care_request(_repo, %{params: params}) do
    {:ok, pending_urgent_care_request} =
      UrgentCare.fetch_pending_urgent_care_request_for_patient(params.patient_id)

    UrgentCare.Request.mark_call_as_started(pending_urgent_care_request.id, DateTime.utc_now())
  end

  defp remove_from_queue(_repo, %{params: params}) do
    :ok = UrgentCare.PatientsQueue.remove_from_queue(params.patient_id)
    {:ok, true}
  end
end
