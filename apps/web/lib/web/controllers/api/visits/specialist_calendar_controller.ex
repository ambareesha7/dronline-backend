defmodule Web.Api.Visits.SpecialistCalendarController do
  use Web, :controller

  action_fallback(Web.FallbackController)

  def show(conn, params) do
    %{"month" => unix, "specialist_id" => specialist_id} = params
    specialist_id = String.to_integer(specialist_id)
    unix = String.to_integer(unix)
    patient_id = conn.assigns.current_patient_id

    {:ok, timeslots} = Visits.fetch_free_specialist_timeslots(specialist_id, unix, patient_id)

    conn |> render("show.proto", %{timeslots: timeslots})
  end

  @decode Proto.Visits.CreateVisitRequest
  def create_visit(
        %{
          assigns: %{
            current_patient_id: patient_id,
            protobuf: %{
              timeslot_params: timeslot_params,
              chosen_medical_category_id: chosen_medical_category_id,
              payments_params: payments_params,
              user_timezone: user_timezone
            }
          }
        } = conn,
        %{
          "specialist_id" => specialist_id
        } = _params
      ) do
    specialist_id = String.to_integer(specialist_id)
    team_id = Teams.specialist_team_id(specialist_id)

    params =
      create_visit_params(%{
        specialist_id: specialist_id,
        patient_id: patient_id,
        team_id: team_id,
        payments_params: payments_params,
        timeslot_params: timeslot_params,
        chosen_medical_category_id: chosen_medical_category_id,
        us_board_request_id: nil,
        user_timezone: user_timezone
      })

    with {:ok, visit} <- Visits.book_visit(params) do
      render(conn, "create.proto", %{visit: visit})
    end
  end

  @decode Proto.Visits.CreateUsBoardVisitRequest
  def create_us_board_visit(
        %{
          assigns: %{
            current_patient_id: patient_id,
            protobuf: %{
              timeslot_params: timeslot_params,
              us_board_request_id: us_board_request_id
            }
          }
        } = conn,
        %{"specialist_id" => specialist_id} = _params
      ) do
    specialist_id = String.to_integer(specialist_id)
    team_id = Teams.specialist_team_id(specialist_id)

    {:ok, medical_category} = Visits.MedicalCategory.fetch_us_board_medical_category()

    params =
      create_visit_params(%{
        specialist_id: specialist_id,
        patient_id: patient_id,
        team_id: team_id,
        timeslot_params: timeslot_params,
        payments_params: nil,
        chosen_medical_category_id: medical_category.id,
        us_board_request_id: us_board_request_id,
        user_timezone: nil
      })

    with {:ok, visit} <- Visits.book_us_board_visit(params) do
      render(conn, "create.proto", %{visit: visit})
    end
  end

  defp create_visit_params(%{
         specialist_id: specialist_id,
         patient_id: patient_id,
         team_id: team_id,
         payments_params: payments_params,
         timeslot_params: timeslot_params,
         chosen_medical_category_id: chosen_medical_category_id,
         us_board_request_id: us_board_request_id,
         user_timezone: user_timezone
       }) do
    %{
      specialist_id: specialist_id,
      patient_id: patient_id,
      team_id: team_id,
      chosen_medical_category_id: chosen_medical_category_id,
      start_time: timeslot_params.start_time,
      visit_type: timeslot_params.visit_type,
      timeslot_params: timeslot_params,
      transaction_reference: fetch_from_struct_or_nil(payments_params, :transaction_reference),
      amount: fetch_from_struct_or_nil(payments_params, :amount),
      currency: fetch_from_struct_or_nil(payments_params, :currency),
      payment_method: fetch_payment_method(payments_params),
      us_board_request_id: us_board_request_id,
      user_timezone: user_timezone
    }
  end

  defp fetch_from_struct_or_nil(nil, _key), do: nil
  defp fetch_from_struct_or_nil(struct, key), do: Map.fetch!(struct, key)

  defp fetch_payment_method(nil), do: nil
  defp fetch_payment_method(%{payment_method: nil}), do: nil

  defp fetch_payment_method(%{payment_method: payment_method}),
    do: payment_method |> Atom.to_string() |> String.downcase()
end

defmodule Web.Api.Visits.SpecialistCalendarView do
  use Web, :view

  def render("create.proto", %{visit: visit}) do
    %Proto.Visits.CreateVisitResponse{
      record_id: visit.record_id
    }
  end

  def render("show.proto", %{timeslots: timeslots}) do
    %Proto.Visits.GetCalendarResponse{
      timeslots: Enum.map(timeslots, &Web.View.Visits.render_timeslot/1)
    }
  end
end
