defmodule Visits do
  import Mockery.Macro

  @us_board_amount "499"
  @us_board_currency "USD"
  @us_board_payment_method :telr

  defmacrop landing_payment_api do
    quote do: mockable(PaymentsApi.Client.Payment, by: PaymentsApi.Client.PaymentMock)
  end

  defdelegate check_if_doctor_can_call_pending_visit(visit_id),
    to: Visits.Commands.CheckIfDoctorCanCallPending,
    as: :call

  defdelegate create_timeslots(cmd),
    to: Visits.Commands.CreateTimeslots,
    as: :call

  defdelegate fetch_all_specialist_timeslots(specialist_id, month_unix),
    to: Visits.MonthSchedule,
    as: :fetch_all_timeslots

  defdelegate fetch_specialists_free_day_schedules_for_future(specialists_id, utc_now),
    to: Visits.MonthSchedule

  defdelegate fetch_specialist_timeslots_setup_for_future(specialist_id, utc_now),
    to: Visits.MonthSchedule

  defdelegate fetch_free_medical_category_timeslots(medical_category_id, month_unix, patient_id),
    to: Visits.MonthSchedule,
    as: :fetch_free_timeslots_for_medical_category

  defdelegate fetch_free_specialist_timeslots(specialist_id, month_unix, patient_id),
    to: Visits.MonthSchedule,
    as: :fetch_free_timeslots

  defdelegate fetch_ended_visits_for_specialist(specialist_id, params),
    to: Visits.EndedVisit,
    as: :fetch_paginated_for_specialist

  defdelegate fetch_visits_for_patients(patient_ids, params),
    to: Visits.Visit,
    as: :fetch_for_patients

  defdelegate fetch_visits_for_record(patient_id, record_id, params),
    to: Visits.Visit,
    as: :fetch_for_record

  defdelegate fetch_pending_visits(gp_id),
    to: Visits.PendingVisit,
    as: :get_pending_visits

  defdelegate fetch_pending_visits_for_specialist(specialist_id, params \\ %{}),
    to: Visits.PendingVisit,
    as: :get_pending_visits_for_specialist

  defdelegate fetch(visit_id),
    to: Visits.Visit

  defdelegate fetch_for_patient(visit_id),
    to: Visits.Visit

  defdelegate move_visit_from_pending_to_canceled(visit_id, params),
    to: Visits.Commands.MoveVisitFromPendingToCanceled,
    as: :call

  defdelegate remove_timeslots(cmd),
    to: Visits.Commands.RemoveTimeslots,
    as: :call

  defdelegate take_timeslot(cmd),
    to: Visits.Commands.TakeTimeslot,
    as: :call

  defdelegate fetch_medical_category(medical_category_id),
    to: Visits.MedicalCategory,
    as: :fetch

  defdelegate fetch_us_board_medical_category(), to: Visits.MedicalCategory

  defdelegate fetch_patient_second_opinion_requests(patient_id),
    to: Visits.USBoard

  defdelegate fetch_us_board_second_opinion(request_id),
    to: Visits.USBoard,
    as: :fetch_second_opinion_request

  defdelegate fetch_second_opinion_request_by_visit_id(visit_id), to: Visits.USBoard

  defdelegate fetch_payment_by_request_id(request_id), to: Visits.USBoard

  defdelegate fetch_specialist_second_opinion_requests(specialist_id), to: Visits.USBoard

  defdelegate update_specialist_opinion(request_id, specialist_opinion),
    to: Visits.USBoard.SecondOpinionRequest

  defdelegate fetch_payment_by_record_and_patient_id(record_id, patient_id),
    to: Visits.Payments,
    as: :fetch_by_record_and_patient_id

  defdelegate fetch_payment_by_record_id(record_id),
    to: Visits.Payments,
    as: :fetch_by_record_id

  defdelegate move_visit_from_pending_to_ended(visit_id),
    to: Visits.Commands.MoveVisitFromPendingToEnded,
    as: :call

  def assign_specialist_to_second_opinion_request(specialist_id, request_id) do
    with {:ok, assigned_specialist} <-
           Visits.USBoard.assign_specialist_to_second_opinion_request(specialist_id, request_id),
         {:ok, specialist} <- Visits.Specialists.Specialist.fetch_by_specialist_id(specialist_id),
         {:ok, _job} <-
           Mailers.send_email(%{
             type: "SPECIALIST_ASSIGNED_TO_US_BOARD_REQUEST",
             specialist_email: specialist.email
           }) do
      {:ok, assigned_specialist}
    end
  end

  def accept_us_board_second_opinion(specialist_id, request_id) do
    with {:ok, specialist} <-
           Visits.USBoard.SecondOpinionAssignedSpecialist.accept_request(
             specialist_id,
             request_id
           ),
         {:ok, request} <-
           Visits.USBoard.move_request_to_in_progress(request_id),
         {:ok, specialist_basic_info} = SpecialistProfile.fetch_basic_info(specialist_id),
         {:ok, _job} <-
           Mailers.send_email(%{
             type: "SPECIALIST_ACCEPTED_US_BOARD_REQUEST",
             specialist_name:
               Mailers.Helpers.format_specialist(
                 specialist_basic_info.first_name,
                 specialist_basic_info.last_name,
                 specialist_basic_info.medical_title
               )
           }) do
      :ok =
        send_notification(%PushNotifications.Message.USBoardRequestAccepted{
          send_to_patient_id: request.patient_id,
          us_board_request_id: request.id
        })

      {:ok, specialist}
    end
  end

  def reject_us_board_second_opinion(specialist_id, request_id) do
    with {:ok, specialist} <-
           Visits.USBoard.SecondOpinionAssignedSpecialist.reject_request(
             specialist_id,
             request_id
           ),
         {:ok, _request} <-
           Visits.USBoard.move_request_to_rejected(request_id),
         {:ok, _job} <- Mailers.send_email(%{type: "SPECIALIST_REJECTED_US_BOARD_REQUEST"}) do
      {:ok, specialist}
    end
  end

  def submit_specialist_opinion(request_id, specialist_opinion) do
    with {:ok, _request} <-
           Visits.USBoard.SecondOpinionRequest.update_specialist_opinion(
             request_id,
             specialist_opinion
           ),
         {:ok, request} <-
           Visits.USBoard.move_request_to_opinion_submitted(request_id) do
      specialist_id = Visits.USBoard.get_accepted_specialist_id(request_id)

      {:ok, specialist_basic_info} = SpecialistProfile.fetch_basic_info(specialist_id)

      {:ok, _job} =
        Mailers.send_email(%{
          type: "SPECIALIST_SUBMITTED_SECOND_OPINION",
          patient_email: request.patient_email,
          us_board_request_id: request_id,
          specialist_name:
            Mailers.Helpers.format_specialist(
              specialist_basic_info.first_name,
              specialist_basic_info.last_name,
              specialist_basic_info.medical_title
            )
        })

      :ok =
        send_notification(%PushNotifications.Message.USBoardOpinionSubmitted{
          send_to_patient_id: request.patient_id,
          us_board_request_id: request.id
        })

      {:ok, request}
    end
  end

  def book_visit(params) do
    cmd = %Visits.Commands.TakeTimeslot{
      specialist_id: params.specialist_id,
      start_time: params.timeslot_params.start_time,
      patient_id: params.patient_id,
      visit_type: params.visit_type,
      chosen_medical_category_id: params[:chosen_medical_category_id],
      us_board_request_id: params[:us_board_request_id]
    }

    with {:ok, visit} <- Visits.Commands.TakeTimeslot.call(cmd),
         params <- Map.put(params, :visit_id, visit.record_id),
         {:ok, payment} <- Visits.Payments.create(params),
         {:ok, _result} <-
           maybe_send_booking_confirmation_email(
             payment,
             visit.chosen_medical_category_id,
             visit.start_time,
             params.user_timezone
           ) do
      {:ok, visit}
    end
  end

  def book_us_board_visit(params) do
    cmd = %Visits.Commands.TakeTimeslot{
      specialist_id: params.specialist_id,
      start_time: params.timeslot_params.start_time,
      patient_id: params.patient_id,
      visit_type: :US_BOARD,
      chosen_medical_category_id: params.chosen_medical_category_id,
      us_board_request_id: params.us_board_request_id
    }

    with {:ok, visit} <- Visits.Commands.TakeTimeslot.call(cmd),
         {:ok, us_board_request} <-
           Visits.USBoard.move_request_to_call_scheduled(params.us_board_request_id, visit.id),
         {:ok, _payment} <-
           Visits.Payments.assign_to_us_board_visit(us_board_request.id, visit.record_id),
         {:ok, specialist} <-
           Visits.Specialists.Specialist.fetch_by_specialist_id(params.specialist_id),
         {:ok, _job} <-
           Mailers.send_email(%{
             type: "PATIENT_SCHEDULED_US_BOARD_CALL",
             specialist_email: specialist.email
           }) do
      {:ok, visit}
    else
      {:error, :invalid_status} ->
        {:error, "Visit can be scheduled only if second opinion request has status in_progress"}
    end
  end

  def request_us_board_second_opinion(params) do
    params =
      Map.merge(params, %{
        amount: us_board_amount(params.patient_email),
        currency: @us_board_currency,
        payment_method: @us_board_payment_method
      })

    with {:ok, us_board_request} <- Visits.USBoard.request_second_opinion(params),
         {:ok, _payment} <- Visits.Payments.create_for_us_board(params, us_board_request.id),
         {:ok, _job} <- Mailers.send_email(%{type: "NEW_US_BOARD_REQUEST"}),
         {:ok, _job} <-
           Mailers.send_email(%{
             type: "PATIENT_US_BOARD_REQUEST_CONFIRMATION",
             patient_email: us_board_request.patient_email,
             us_board_request_id: us_board_request.id
           }) do
      :ok =
        send_notification(%PushNotifications.Message.USBoardRequestConfirmation{
          send_to_patient_id: us_board_request.patient_id,
          us_board_request_id: us_board_request.id
        })

      {:ok, us_board_request}
    end
  end

  def request_second_opinion_from_landing(%{status: :landing_payment_pending} = params) do
    with {:ok, us_board_request} <- Visits.USBoard.request_second_opinion(params),
         {:ok, _job} <- Mailers.send_email(%{type: "NEW_US_BOARD_REQUEST"}),
         payment_params = merge_payment_params(params, us_board_request),
         {:ok, %{payment_url: payment_url}} <-
           landing_payment_api().get_payment_url(payment_params) do
      {:ok, %{us_board_request_id: us_board_request.id, payment_url: payment_url}}
    end
  end

  def request_second_opinion_from_landing(%{status: :landing_form} = params) do
    with {:ok, us_board_request} <- Visits.USBoard.request_second_opinion(params),
         {:ok, _job} <- Mailers.send_email(%{type: "NEW_US_BOARD_REQUEST"}),
         {:ok, _job} <-
           Mailers.send_email(%{
             type: "PATIENT_US_BOARD_REQUEST_CONFIRMATION",
             patient_email: us_board_request.patient_email,
             us_board_request_id: us_board_request.id
           }) do
      {:ok, us_board_request}
    end
  end

  def confirm_second_opinion_payment(params) do
    params =
      Map.merge(params, %{
        amount: us_board_amount_by_request_id(params.us_board_second_opinion_request_id),
        currency: @us_board_currency,
        payment_method: @us_board_payment_method
      })

    with {:ok, _payment} <-
           Visits.Payments.create_for_us_board(params, params.us_board_second_opinion_request_id),
         {:ok, request} <-
           Visits.USBoard.move_request_to_landing_booking(
             params.us_board_second_opinion_request_id
           ),
         {:ok, _job} <-
           Mailers.send_email(%{
             type: "PATIENT_US_BOARD_REQUEST_CONFIRMATION",
             patient_email: request.patient_email,
             us_board_request_id: request.id
           }) do
      :ok
    end
  end

  def maybe_move_us_board_request_to_done(record_id) do
    with {:ok, visit} <- Visits.Visit.fetch_by_record_id(record_id),
         {:ok, request} <- Visits.USBoard.fetch_second_opinion_request_by_visit_id(visit.id) do
      Visits.USBoard.move_request_to_done(request.id)
    end
  end

  # reduce amount to this email
  defp us_board_amount("ravin@dronline.ai"), do: "1"
  defp us_board_amount(_patient_email), do: @us_board_amount

  defp us_board_amount_by_request_id(request_id) do
    {:ok, %{patient_email: patient_email}} =
      Visits.USBoard.fetch_second_opinion_request(request_id)

    us_board_amount(patient_email)
  end

  defp maybe_send_booking_confirmation_email(
         %Visits.Visit.Payment{
           payment_method: :telr,
           price: %{amount: amount, currency: currency},
           patient_id: patient_id,
           specialist_id: specialist_id,
           inserted_at: payment_date
         },
         medical_category_id,
         visit_date,
         user_timezone
       ) do
    {:ok, basic_info} = PatientProfile.fetch_basic_info(patient_id)

    {:ok,
     %SpecialistProfile.BasicInfo{
       first_name: specialist_first_name,
       last_name: specialist_last_name,
       medical_title: specialist_medical_title
     }} = SpecialistProfile.fetch_basic_info(specialist_id)

    {:ok, medical_category} = Visits.fetch_medical_category(medical_category_id)

    {:ok, _job} =
      Mailers.send_email(%{
        type: "VISIT_BOOKING_CONFIRMATION",
        patient_email: basic_info.email,
        amount: amount,
        currency: currency,
        payment_date: Mailers.Helpers.humanize_datetime(payment_date, user_timezone),
        visit_date: Mailers.Helpers.humanize_datetime(visit_date, user_timezone),
        medical_category_name: medical_category.name,
        specialist_name:
          Mailers.Helpers.format_specialist(
            specialist_first_name,
            specialist_last_name,
            specialist_medical_title
          )
      })
  end

  defp maybe_send_booking_confirmation_email(
         _payment,
         _medical_category_id,
         _visit_date,
         _user_timezone
       ),
       do: {:ok, nil}

  defp send_notification(notification_struct) do
    mockable(PushNotifications.Message).send(notification_struct)
  end

  defp merge_payment_params(params, us_board_request) do
    base_params = %{
      ref: us_board_request.id,
      amount: us_board_amount(params.patient_email),
      currency: @us_board_currency,
      description: "US Board second opinion for #{us_board_request.patient_email}",
      host: params.host
    }

    user_data = %{
      email: params.patient_email,
      first_name: params.first_name,
      last_name: params.last_name
    }

    Map.put(base_params, :user_data, user_data)
  end
end
