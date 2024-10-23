defmodule Web.View.Visits do
  def render_emr_visit_data_for_patient(visit) do
    %Proto.Visits.VisitDataForPatient{
      id: visit.id,
      status: visit.status |> Proto.enum(Proto.Visits.VisitDataForPatient.Status),
      start_time: visit.start_time,
      specialist_id: visit.specialist_id,
      record_id: visit.record_id,
      patient_id: visit.patient_id,
      visit_type: visit.visit_type
    }
  end

  def render_visit_data_for_patient(%{
        visit: visit,
        medical_category: medical_category,
        payment: payment,
        us_board_payment: us_board_payment
      }) do
    %Proto.Visits.VisitDataForPatient{
      id: visit.id,
      status: visit.status |> Proto.enum(Proto.Visits.VisitDataForPatient.Status),
      start_time: visit.start_time,
      specialist_id: visit.specialist_id,
      record_id: visit.record_id,
      patient_id: visit.patient_id,
      payments_params: render_payment_params(payment, us_board_payment),
      medical_category: render_medical_category(medical_category)
    }
  end

  def render_visit_data_for_specialist(visit) do
    %Proto.Visits.VisitDataForSpecialist{
      id: visit.id,
      patient_id: visit.patient_id,
      record_id: visit.record_id,
      scheduled_with: visit.specialist_id,
      starts_at: visit.start_time,
      scheduled_at: visit.inserted_at |> Timex.to_unix(),
      chosen_medical_category_id: visit.chosen_medical_category_id,
      state:
        visit.state
        |> String.to_existing_atom()
        |> Proto.enum(Proto.Visits.VisitDataForSpecialist.State),
      type: visit_type(visit.chosen_medical_category_id, Map.get(visit, :visit_type))
    }
  end

  def render_timeslot(%Visits.FreeTimeslot{} = timeslot) do
    %Proto.Visits.Timeslot{
      start_time: timeslot.start_time,
      status: {:free, %Proto.Visits.Timeslot.Free{visit_type: timeslot.visit_type}}
    }
  end

  def render_timeslot(%Visits.TakenTimeslot{} = timeslot) do
    %Proto.Visits.Timeslot{
      start_time: timeslot.start_time,
      status:
        {:taken,
         %Proto.Visits.Timeslot.Taken{
           patient_id: timeslot.patient_id,
           record_id: timeslot.record_id,
           visit_id: timeslot.visit_id,
           visit_type: timeslot.visit_type
         }}
    }
  end

  def render_medical_category_timeslot(medical_category_timeslot) do
    %Proto.Visits.MedicalCategoryTimeslot{
      start_time: medical_category_timeslot.start_time,
      available_specialist_ids: medical_category_timeslot.available_specialist_ids
    }
  end

  def render_medical_category(nil), do: nil

  def render_medical_category(medical_category) do
    %Proto.Visits.MedicalCategory{
      id: medical_category.id,
      name: medical_category.name,
      parent_category_id: medical_category.parent_category_id
    }
  end

  def render_day_schedule(day_schedule) do
    %Proto.Visits.DaySchedule{
      id: day_schedule.id,
      specialist_id: day_schedule.specialist_id,
      date: Web.View.Generics.render_datetime(day_schedule.date),
      free_timeslots: Enum.map(day_schedule.free_timeslots, &render_timeslot/1),
      taken_timeslots: Enum.map(day_schedule.taken_timeslots, &render_timeslot/1),
      free_timeslots_count: day_schedule.free_timeslots_count,
      taken_timeslots_count: day_schedule.taken_timeslots_count
    }
  end

  def render_us_board_second_opinion_request(request) do
    %Proto.Visits.USBoardSecondOpinionRequest{
      id: request.id,
      specialist_id: request |> Map.get(:assigned_specialists) |> assigned_specialist_id(),
      patient_id: request.patient_id,
      visit_id: request.visit_id,
      inserted_at: request.inserted_at |> Web.View.Generics.render_datetime(),
      patient_description: request.patient_description,
      specialist_opinion: request.specialist_opinion,
      patient_email: request.patient_email,
      status: Web.ProtoHelpers.map_us_board_second_opinion_status(request.status),
      files: Enum.map(request.files, &render_us_board_second_opinion_request_files/1),
      payments_params: render_payment_params(request.us_board_second_opinion_request_payment),
      specialists_history:
        request
        |> Map.get(:specialists_history)
        |> render_us_board_second_opinion_specialists_history()
    }
  end

  defp render_us_board_second_opinion_request_files(%{path: nil}) do
    %Proto.Visits.USBoardFilesToDownload{
      download_url: nil
    }
  end

  defp render_us_board_second_opinion_request_files(%{path: path}) do
    %Proto.Visits.USBoardFilesToDownload{
      download_url: Upload.signed_download_url(path)
    }
  end

  defp assigned_specialist_id([]), do: nil

  defp assigned_specialist_id(specialists) do
    specialists
    |> Enum.filter(&(&1.status in [:assigned, :accepted]))
    |> Enum.sort(&(&1.assigned_at > &2.assigned_at))
    |> List.first()
    |> case do
      %Visits.USBoard.SecondOpinionAssignedSpecialist{} = specialist ->
        Map.get(specialist, :specialist_id)

      %Admin.USBoard.SecondOpinionRequest.AssignedSpecialist{} = specialist ->
        Map.get(specialist, :specialist_id)

      _ ->
        nil
    end
  end

  defp render_payment_params(%Visits.Visit.Payment{} = payment, nil) do
    render_payment_params(payment)
  end

  defp render_payment_params(
         nil,
         %Visits.USBoard.SecondOpinionRequestPayment{} = us_board_payment
       ) do
    render_payment_params(us_board_payment)
  end

  defp render_payment_params(nil, nil) do
    render_payment_params(nil)
  end

  defp render_payment_params(nil) do
    %Proto.Visits.PaymentsParams{
      amount: "",
      currency: "",
      transaction_reference: "",
      payment_method: Web.ProtoHelpers.map_payment_method(nil)
    }
  end

  defp render_payment_params(payment) do
    %Proto.Visits.PaymentsParams{
      amount: Integer.to_string(payment.price.amount),
      currency: Atom.to_string(payment.price.currency),
      transaction_reference: payment.transaction_reference,
      payment_method: Web.ProtoHelpers.map_payment_method(payment.payment_method)
    }
  end

  defp render_us_board_second_opinion_specialists_history(nil), do: []

  defp render_us_board_second_opinion_specialists_history(specialists_history) do
    Enum.map(
      specialists_history,
      &%Proto.Visits.SpecialistHistory{
        specialist_id: &1.specialist_id,
        rejected_at: Web.View.Generics.render_datetime(&1.rejected_at),
        accepted_at: Web.View.Generics.render_datetime(&1.accepted_at),
        assigned_at: Web.View.Generics.render_datetime(&1.assigned_at),
        specialist_first_name: &1.specialist_first_name,
        specialist_last_name: &1.specialist_last_name
      }
    )
  end

  defp visit_type(chosen_medical_category_id, type) do
    {:ok, %{id: us_board_medical_category_id}} = Visits.fetch_us_board_medical_category()

    type =
      cond do
        type == :IN_OFFICE -> :IN_OFFICE
        chosen_medical_category_id == us_board_medical_category_id -> :US_BOARD
        true -> :ONLINE
      end

    Proto.enum(type, Proto.Visits.VisitDataForSpecialist.Type)
  end
end
