defmodule UrgentCare.PatientsQueue.Cancel do
  alias Ecto.Multi
  alias EMR.PatientRecords.PatientRecord
  alias Postgres.Repo

  import Mockery.Macro

  defmacrop refund_api do
    quote do: mockable(PaymentsApi.Client.Refund, by: PaymentsApi.Client.RefundMock)
  end

  def call(args) do
    Multi.new()
    |> Multi.run(:params, &get_params(&1, &2, args))
    |> Multi.run(:remove_from_patients_queue, &remove_from_patients_queue/2)
    |> Multi.run(:insert_refund, &insert_refund/2)
    |> Multi.run(:cancel_urgent_care_request, &cancel_urgent_care_request/2)
    |> Multi.run(:cancel_patient_record, &cancel_patient_record/2)
    |> Multi.run(:broadcast_patients_queue_update, fn _, _ ->
      Calls.ChannelBroadcast.broadcast(:patients_queue_update)
      {:ok, true}
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{cancel_urgent_care_request: request}} ->
        {:ok, request}

      {:error, _failed_operation, reason, _changes_so_far} ->
        {:error, reason}
    end
  end

  defp get_params(_repo, _multi, args) do
    with {:ok, pending_urgent_care_request} when not is_nil(pending_urgent_care_request) <-
           UrgentCare.fetch_pending_urgent_care_request_for_patient(args.patient_id) do
      {:ok, Map.put(args, :pending_urgent_care_request, pending_urgent_care_request)}
    else
      {:error, :not_found} -> {:error, :no_pending_urgent_care_request}
    end
  end

  defp remove_from_patients_queue(_repo, %{params: params}) do
    :ok = UrgentCare.PatientsQueue.Remove.call(params.patient_id)

    {:ok, true}
  end

  defp insert_refund(_repo, %{params: params}) do
    payment = params.pending_urgent_care_request.payment

    if UrgentCare.Payments.get_refund_for_payment(payment.id) do
      {:error, :refund_already_created}
    else
      {:ok, refund} =
        UrgentCare.Payments.create_refund(%{
          reason: params.reason,
          payment_id: payment.id
        })

      refund_api().refund_visit(
        payment.transaction_reference,
        payment.price.amount,
        payment.price.currency
      )

      {:ok, refund}
    end
  end

  defp cancel_urgent_care_request(_repo, %{params: params}) do
    if params.pending_urgent_care_request.canceled_at do
      {:error, :urgent_care_request_already_canceled}
    else
      {:ok, _} =
        UrgentCare.Request.cancel(params.pending_urgent_care_request.id, DateTime.utc_now())
    end
  end

  defp cancel_patient_record(_repo, %{params: params}) do
    PatientRecord.cancel(params.patient_id, params.pending_urgent_care_request.patient_record_id)
    {:ok, :closed}
  end
end
