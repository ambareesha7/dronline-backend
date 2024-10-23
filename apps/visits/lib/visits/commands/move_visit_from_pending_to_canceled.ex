defmodule Visits.Commands.MoveVisitFromPendingToCanceled do
  use Postgres.Service

  import Mockery.Macro

  alias Ecto.Multi
  alias EMR.PatientRecords.PatientRecord
  alias Visits.CanceledVisit
  alias Visits.DaySchedule
  alias Visits.PendingVisit

  @refund_hour_limit 24

  defmacrop channel_broadcast do
    quote do: mockable(ChannelBroadcast, by: ChannelBroadcastMock)
  end

  defmacrop notification do
    quote do: mockable(PushNotifications.Message)
  end

  defmacrop refund_api do
    quote do: mockable(PaymentsApi.Client.Refund, by: PaymentsApi.Client.RefundMock)
  end

  @spec call(pos_integer, map) ::
          {:ok, %CanceledVisit{}} | {:error, Ecto.Changeset.t()} | {:error, String.t()}
  def call(visit_id, params) do
    pending_visit = PendingVisit.get(visit_id)
    canceled_visit_changeset = CanceledVisit.changeset(pending_visit, params)

    payment = Visits.Visit.Payment.by_visit_id(pending_visit.record_id)

    Multi.new()
    |> cancel_record_multi(pending_visit)
    |> reclaim_timeslot_multi(pending_visit)
    |> Multi.insert(:insert_canceled_visit, canceled_visit_changeset)
    |> Multi.run(
      :refund_visit,
      &maybe_insert_refund(&1, &2, %{
        visit: pending_visit,
        canceled_by: params["canceled_by"],
        payment: payment
      })
    )
    |> Multi.delete(:delete_pending_visit, pending_visit)
    |> Repo.transaction()
    |> case do
      {:ok, %{insert_canceled_visit: canceled_visit, refund_visit: refund}} ->
        handle_side_effects(canceled_visit, refund, payment)
        {:ok, canceled_visit}

      {:error, _, %Ecto.Changeset{} = changeset, _} ->
        {:error, changeset}
    end
  end

  # condition for free visits,
  # it should be deleted later once all of the specialists have prices
  defp maybe_insert_refund(_repo, _multi_result, %{
         visit: _visit,
         canceled_by: _canceled_by,
         payment: nil
       }),
       do: {:ok, nil}

  # doesn't do refund when payment was outside the system
  defp maybe_insert_refund(_repo, _multi_result, %{
         visit: visit,
         canceled_by: canceled_by,
         payment: %{payment_method: :external} = payment
       }) do
    canceled_by
    |> convert_canceled_by()
    |> apply_refund_conditions(visit, payment)
    |> case do
      {:ok, %Visits.Visit.Payment.Refund{} = refund} ->
        {:ok, refund}

      {:ok, nil} ->
        {:ok, nil}
    end
  end

  defp maybe_insert_refund(_repo, _multi_result, %{
         visit: visit,
         canceled_by: canceled_by,
         payment: payment
       }) do
    canceled_by
    |> convert_canceled_by()
    |> apply_refund_conditions(visit, payment)
    |> case do
      {:ok, %Visits.Visit.Payment.Refund{} = refund} ->
        refund_api().refund_visit(
          payment.transaction_reference,
          payment.price.amount,
          payment.price.currency
        )

        {:ok, refund}

      {:ok, nil} ->
        {:ok, nil}
    end
  end

  defp apply_refund_conditions(:specialist = requested_by, visit, payment) do
    Visits.Payments.refund(%{
      requested_by: requested_by,
      requester_id: visit.specialist_id,
      payment_id: payment.id
    })
  end

  defp apply_refund_conditions(:patient = requested_by, visit, payment) do
    now = DateTime.utc_now()
    visit_start_time = Timex.from_unix(visit.start_time, :second)

    # uses minutes to accurately check if it's before 24h
    diff = Timex.diff(visit_start_time, now, :minutes) / 60

    if diff > @refund_hour_limit do
      Visits.Payments.refund(%{
        requested_by: requested_by,
        requester_id: visit.patient_id,
        payment_id: payment.id
      })
    else
      {:ok, nil}
    end
  end

  defp convert_canceled_by("patient"), do: :patient
  defp convert_canceled_by("doctor"), do: :specialist

  defp cancel_record_multi(
         %Ecto.Multi{} = multi,
         %PendingVisit{
           record_id: record_id,
           patient_id: patient_id
         }
       ) do
    multi
    |> Multi.run(:cancel_patient_record, fn _, _ ->
      :ok = PatientRecord.cancel(patient_id, record_id)
      {:ok, nil}
    end)
  end

  defp reclaim_timeslot_multi(%Ecto.Multi{} = multi, %PendingVisit{
         specialist_id: specialist_id,
         start_time: start_time
       }) do
    date = unix_to_date(start_time)

    multi
    |> Ecto.Multi.run(:reclaim_timeslot, fn _, _ ->
      with day_schedules <- DaySchedule.lock_for_update(specialist_id, [date]),
           {:ok, _updated_day_schedule} <- reclaim_timeslot(start_time, day_schedules) do
        {:ok, nil}
      end
    end)
  end

  # Allow empty DaySchedule for specified date, for easier testing.
  defp reclaim_timeslot(_start_time, []), do: {:ok, nil}

  defp reclaim_timeslot(start_time, [day_schedule]) do
    {reclaimed_timeslots, new_taken_timeslots} =
      day_schedule.taken_timeslots
      |> Enum.split_with(&(&1.start_time == start_time))

    new_free_timeslots =
      day_schedule.free_timeslots
      |> Enum.concat(reclaimed_timeslots)

    {:ok, _updated_day_schedule} =
      DaySchedule.insert_or_update(
        day_schedule,
        new_free_timeslots,
        new_taken_timeslots
      )
  end

  defp unix_to_date(unix) do
    unix |> Timex.from_unix(:second) |> Timex.to_date()
  end

  defp handle_side_effects(visit, refund, payment) do
    channel_broadcast().broadcast(:pending_visits_update)
    channel_broadcast().broadcast({:doctor_pending_visits_update, visit.specialist_id})

    send_notification(visit, refund, payment)

    :ok
  end

  defp send_notification(%CanceledVisit{canceled_by: "doctor"} = visit, refund, payment) do
    {:ok, basic_info} = SpecialistProfile.fetch_basic_info(visit.specialist_id)

    notification().send(%PushNotifications.Message.VisitCanceledForPatient{
      patient_id: visit.patient_id,
      record_id: visit.record_id,
      specialist_id: visit.specialist_id,
      specialist_title: basic_info.title,
      specialist_first_name: basic_info.first_name,
      specialist_last_name: basic_info.last_name,
      visit_start_time: visit.start_time,
      is_refunded: refunded?(refund, payment)
    })
  end

  defp send_notification(%CanceledVisit{canceled_by: "patient"} = visit, _refund, _payment) do
    {:ok, basic_info} = PatientProfile.fetch_basic_info(visit.patient_id)

    notification().send(%PushNotifications.Message.VisitCanceledForSpecialist{
      patient_id: visit.patient_id,
      record_id: visit.record_id,
      specialist_id: visit.specialist_id,
      patient_first_name: basic_info.first_name,
      patient_last_name: basic_info.last_name,
      visit_start_time: visit.start_time
    })
  end

  # only when refund was made Visits.Visit.Payment.Refund struct has information about the payment
  defp refunded?(nil, _payment), do: false
  defp refunded?(_refund, %Visits.Visit.Payment{payment_method: :external}), do: false
  defp refunded?(_refund, %Visits.Visit.Payment{payment_method: :telr}), do: true
end
