defmodule Web.PanelApi.Visits.VisitControllerTest do
  use Web.ConnCase, async: false

  import Mockery.Assertions

  alias Proto.Visits.GetDoctorPendingVisitsResponse
  alias Proto.Visits.GetEndedVisitsResponse
  alias Proto.Visits.GetPaymentForVisit
  alias Proto.Visits.GetPendingVisitsResponse
  alias Proto.Visits.GetUploadedDocuments

  setup do
    %{id: id} =
      SpecialistProfile.Factory.insert(:medical_category, name: "U.S Board Second Opinion")

    patient = PatientProfile.Factory.insert(:patient)
    _ = PatientProfile.Factory.insert(:basic_info, patient_id: patient.id)

    {:ok, team} = Teams.create_team(random_id(), %{})

    [us_board_category_id: id, patient: patient, team: team]
  end

  describe "GET pending for a GP" do
    setup [:authenticate_gp]

    test "returns list of upcoming visits and lists of associated specialists and patients", %{
      conn: conn,
      current_gp: gp,
      patient: patient,
      team: team
    } do
      doctor = Authentication.Factory.insert(:specialist, type: "EXTERNAL")
      _ = SpecialistProfile.Factory.insert(:basic_info, specialist_id: doctor.id)

      :ok = add_to_team(team_id: team.id, specialist_id: doctor.id)
      :ok = add_to_team(team_id: team.id, specialist_id: gp.id)

      date = Date.utc_today()
      start_time = DateTime.utc_now() |> Timex.to_unix()

      {:ok, _day_schedule} =
        Visits.DaySchedule.insert_or_update(
          %Visits.DaySchedule{specialist_id: doctor.id, date: date},
          [%{start_time: start_time, visit_type: :ONLINE}],
          []
        )

      cmd = %Visits.Commands.TakeTimeslot{
        specialist_id: doctor.id,
        start_time: start_time,
        patient_id: patient.id,
        chosen_medical_category_id: 1,
        visit_type: :ONLINE
      }

      {:ok, pending_visit} = Visits.take_timeslot(cmd)

      conn = get(conn, panel_visits_visit_path(conn, :pending))

      assert %GetPendingVisitsResponse{
               visits: [fetched_visit],
               specialists: [fetched_specialist],
               patients: [fetched_patient]
             } = proto_response(conn, 200, GetPendingVisitsResponse)

      assert fetched_visit.id == pending_visit.id
      assert fetched_specialist.id == doctor.id
      assert fetched_patient.id == patient.id
    end
  end

  describe "GET pending for a Specialist" do
    setup [:authenticate_external]

    setup %{current_external: doctor, team: team} do
      :ok = add_to_team(team_id: team.id, specialist_id: doctor.id)
    end

    test "returns list of upcoming visits and lists of associated patients for ONLINE visits", %{
      conn: conn,
      current_external: doctor,
      patient: patient
    } do
      date = Date.utc_today()
      start_time = DateTime.utc_now() |> Timex.to_unix()

      {:ok, _day_schedule} =
        Visits.DaySchedule.insert_or_update(
          %Visits.DaySchedule{specialist_id: doctor.id, date: date},
          [%{start_time: start_time, visit_type: :ONLINE}],
          []
        )

      cmd = %Visits.Commands.TakeTimeslot{
        specialist_id: doctor.id,
        start_time: start_time,
        patient_id: patient.id,
        chosen_medical_category_id: 1,
        visit_type: :ONLINE
      }

      {:ok, pending_visit} = Visits.take_timeslot(cmd)

      conn =
        get(conn, panel_visits_visit_path(conn, :pending_for_specialist))

      assert %GetDoctorPendingVisitsResponse{
               visits: [fetched_visit],
               patients: [fetched_patient]
             } = proto_response(conn, 200, GetDoctorPendingVisitsResponse)

      assert fetched_visit.id == pending_visit.id
      assert fetched_visit.type == :ONLINE
      assert fetched_patient.id == patient.id
    end

    test "returns list of upcoming IN_OFFICE visits",
         %{
           conn: conn,
           current_external: doctor,
           patient: patient
         } do
      date = Date.utc_today()
      start_time = DateTime.utc_now() |> Timex.to_unix()

      {:ok, _day_schedule} =
        Visits.DaySchedule.insert_or_update(
          %Visits.DaySchedule{specialist_id: doctor.id, date: date},
          [%{start_time: start_time, visit_type: :IN_OFFICE}],
          []
        )

      cmd = %Visits.Commands.TakeTimeslot{
        specialist_id: doctor.id,
        start_time: start_time,
        patient_id: patient.id,
        chosen_medical_category_id: 1,
        visit_type: :IN_OFFICE
      }

      {:ok, pending_visit} = Visits.take_timeslot(cmd)

      conn =
        get(conn, panel_visits_visit_path(conn, :pending_for_specialist))

      assert %GetDoctorPendingVisitsResponse{
               visits: [fetched_visit],
               patients: [fetched_patient]
             } = proto_response(conn, 200, GetDoctorPendingVisitsResponse)

      assert fetched_visit.id == pending_visit.id
      assert fetched_visit.type == :IN_OFFICE
      assert fetched_patient.id == patient.id
    end

    test "returns list of upcoming US Board visits", %{
      conn: conn,
      current_external: doctor,
      us_board_category_id: us_board_category_id,
      patient: patient
    } do
      date = Date.utc_today()
      start_time = DateTime.utc_now() |> Timex.to_unix()

      {:ok, _day_schedule} =
        Visits.DaySchedule.insert_or_update(
          %Visits.DaySchedule{specialist_id: doctor.id, date: date},
          [%{start_time: start_time, visit_type: :ONLINE}],
          []
        )

      cmd = %Visits.Commands.TakeTimeslot{
        specialist_id: doctor.id,
        start_time: start_time,
        patient_id: patient.id,
        chosen_medical_category_id: us_board_category_id,
        visit_type: :ONLINE
      }

      {:ok, pending_visit} = Visits.take_timeslot(cmd)

      conn = get(conn, panel_visits_visit_path(conn, :pending_for_specialist, today: true))

      assert %GetDoctorPendingVisitsResponse{
               visits: [fetched_visit],
               patients: [fetched_patient]
             } = proto_response(conn, 200, GetDoctorPendingVisitsResponse)

      assert fetched_visit.id == pending_visit.id
      assert fetched_visit.type == :US_BOARD
      assert fetched_patient.id == patient.id
    end

    test "when `exclude_today: true`, filters out today's visits", %{
      conn: conn,
      current_external: doctor,
      patient: patient
    } do
      date = Date.utc_today()
      tommorow = Date.utc_today() |> Date.add(1)
      start_time_today = DateTime.utc_now() |> Timex.to_unix()
      start_time_tomorrow = DateTime.utc_now() |> Timex.shift(days: 1) |> Timex.to_unix()

      {:ok, _day_schedule_today} =
        Visits.DaySchedule.insert_or_update(
          %Visits.DaySchedule{specialist_id: doctor.id, date: date},
          [
            %{start_time: start_time_today, visit_type: :IN_OFFICE}
          ],
          []
        )

      {:ok, _day_schedule_today} =
        Visits.DaySchedule.insert_or_update(
          %Visits.DaySchedule{specialist_id: doctor.id, date: tommorow},
          [
            %{start_time: start_time_tomorrow, visit_type: :ONLINE}
          ],
          []
        )

      {:ok, _today_visit} =
        Visits.take_timeslot(%Visits.Commands.TakeTimeslot{
          specialist_id: doctor.id,
          start_time: start_time_today,
          patient_id: patient.id,
          chosen_medical_category_id: 1,
          visit_type: :IN_OFFICE
        })

      {:ok, tomorrow_visit} =
        Visits.take_timeslot(%Visits.Commands.TakeTimeslot{
          specialist_id: doctor.id,
          start_time: start_time_tomorrow,
          patient_id: patient.id,
          chosen_medical_category_id: 1,
          visit_type: :ONLINE
        })

      conn =
        get(
          conn,
          panel_visits_visit_path(conn, :pending_for_specialist, exclude_today: true)
        )

      assert %GetDoctorPendingVisitsResponse{visits: visits} =
               proto_response(conn, 200, GetDoctorPendingVisitsResponse)

      tommorow_visit_id = tomorrow_visit.id

      assert [%{id: ^tommorow_visit_id}] = Enum.map(visits, &Map.take(&1, [:id]))
    end

    test "returns limited list, when limit and types params are added", %{
      conn: conn,
      current_external: doctor,
      patient: patient
    } do
      date = Date.utc_today()
      start_time_1 = DateTime.utc_now() |> Timex.to_unix()
      start_time_2 = DateTime.utc_now() |> Timex.shift(hours: 1) |> Timex.to_unix()
      start_time_3 = DateTime.utc_now() |> Timex.shift(hours: 2) |> Timex.to_unix()
      start_time_4 = DateTime.utc_now() |> Timex.shift(hours: 3) |> Timex.to_unix()

      {:ok, _day_schedule} =
        Visits.DaySchedule.insert_or_update(
          %Visits.DaySchedule{specialist_id: doctor.id, date: date},
          [
            %{start_time: start_time_1, visit_type: :BOTH},
            %{start_time: start_time_2, visit_type: :BOTH},
            %{start_time: start_time_3, visit_type: :BOTH},
            %{start_time: start_time_4, visit_type: :BOTH}
          ],
          []
        )

      {:ok, online_visit_1} =
        Visits.take_timeslot(%Visits.Commands.TakeTimeslot{
          specialist_id: doctor.id,
          start_time: start_time_1,
          patient_id: patient.id,
          chosen_medical_category_id: 1,
          visit_type: :ONLINE
        })

      {:ok, _in_office_visit} =
        Visits.take_timeslot(%Visits.Commands.TakeTimeslot{
          specialist_id: doctor.id,
          start_time: start_time_2,
          patient_id: patient.id,
          chosen_medical_category_id: 1,
          visit_type: :IN_OFFICE
        })

      {:ok, online_visit_2} =
        Visits.take_timeslot(%Visits.Commands.TakeTimeslot{
          specialist_id: doctor.id,
          start_time: start_time_3,
          patient_id: patient.id,
          chosen_medical_category_id: 1,
          visit_type: :ONLINE
        })

      {:ok, _online_visit_3} =
        Visits.take_timeslot(%Visits.Commands.TakeTimeslot{
          specialist_id: doctor.id,
          start_time: start_time_4,
          patient_id: patient.id,
          chosen_medical_category_id: 1,
          visit_type: :ONLINE
        })

      conn =
        get(
          conn,
          panel_visits_visit_path(conn, :pending_for_specialist,
            today: true,
            limit: 2,
            visit_types: [:ONLINE]
          )
        )

      assert %GetDoctorPendingVisitsResponse{visits: visits} =
               proto_response(conn, 200, GetDoctorPendingVisitsResponse)

      assert [
               %{id: online_visit_1.id, type: :ONLINE},
               %{id: online_visit_2.id, type: :ONLINE}
             ] == Enum.map(visits, &Map.take(&1, [:id, :type]))
    end

    test "returns today's visits, when today: true is added", %{
      conn: conn,
      current_external: doctor,
      patient: patient
    } do
      today_date = Date.utc_today()
      today_start_time = DateTime.utc_now() |> Timex.to_unix()

      tommorrow_date = Date.utc_today() |> Timex.shift(days: 1)
      tommorrow_start_time = DateTime.utc_now() |> Timex.shift(days: 1) |> Timex.to_unix()

      {:ok, _day_schedule} =
        Visits.DaySchedule.insert_or_update(
          %Visits.DaySchedule{specialist_id: doctor.id, date: today_date},
          [%{start_time: today_start_time, visit_type: :BOTH}],
          []
        )

      {:ok, _day_schedule} =
        Visits.DaySchedule.insert_or_update(
          %Visits.DaySchedule{specialist_id: doctor.id, date: tommorrow_date},
          [%{start_time: tommorrow_start_time, visit_type: :BOTH}],
          []
        )

      {:ok, today_visit} =
        Visits.take_timeslot(%Visits.Commands.TakeTimeslot{
          specialist_id: doctor.id,
          start_time: today_start_time,
          patient_id: patient.id,
          chosen_medical_category_id: 1,
          visit_type: :ONLINE
        })

      {:ok, _tommorrow_visit} =
        Visits.take_timeslot(%Visits.Commands.TakeTimeslot{
          specialist_id: doctor.id,
          start_time: tommorrow_start_time,
          patient_id: patient.id,
          chosen_medical_category_id: 1,
          visit_type: :ONLINE
        })

      conn =
        get(conn, panel_visits_visit_path(conn, :pending_for_specialist, today: true))

      assert %GetDoctorPendingVisitsResponse{visits: visits} =
               proto_response(conn, 200, GetDoctorPendingVisitsResponse)

      assert [%{id: today_visit.id}] == Enum.map(visits, &Map.take(&1, [:id]))
    end
  end

  describe "GET ended" do
    setup [:authenticate_external]

    test "returns list of ended visits and lists of associated patients", %{
      conn: conn,
      current_external: doctor,
      patient: patient
    } do
      date = Date.utc_today()
      start_time = DateTime.utc_now() |> Timex.to_unix()

      {:ok, _day_schedule} =
        Visits.DaySchedule.insert_or_update(
          %Visits.DaySchedule{specialist_id: doctor.id, date: date},
          [%{start_time: start_time, visit_type: :ONLINE}],
          []
        )

      cmd = %Visits.Commands.TakeTimeslot{
        specialist_id: doctor.id,
        start_time: start_time,
        patient_id: patient.id,
        chosen_medical_category_id: 1,
        visit_type: :ONLINE
      }

      {:ok, pending_visit} = Visits.take_timeslot(cmd)
      {:ok, ended_visit} = Visits.move_visit_from_pending_to_ended(pending_visit.id)

      conn = get(conn, panel_visits_visit_path(conn, :ended))

      assert %GetEndedVisitsResponse{
               visits: [fetched_visit],
               patients: [fetched_patient],
               next_token: ""
             } = proto_response(conn, 200, GetEndedVisitsResponse)

      assert fetched_visit.id == ended_visit.id
      assert fetched_patient.id == patient.id
    end
  end

  describe "POST move_to_canceled" do
    setup [:authenticate_external]

    test "moves pending visit to canceled", %{
      conn: conn,
      current_external: doctor,
      patient: patient,
      team: team
    } do
      date = Date.utc_today()
      start_time = DateTime.utc_now() |> Timex.to_unix()

      :ok = add_to_team(team_id: team.id, specialist_id: doctor.id)

      {:ok, _day_schedule} =
        Visits.DaySchedule.insert_or_update(
          %Visits.DaySchedule{specialist_id: doctor.id, date: date},
          [%{start_time: start_time, visit_type: :ONLINE}],
          []
        )

      cmd = %Visits.Commands.TakeTimeslot{
        specialist_id: doctor.id,
        start_time: start_time,
        patient_id: patient.id,
        chosen_medical_category_id: 1,
        visit_type: :ONLINE
      }

      {:ok, pending_visit} = Visits.take_timeslot(cmd)

      {:ok, payment} =
        Visits.Payments.create(%{
          visit_id: pending_visit.record_id,
          patient_id: patient.id,
          specialist_id: doctor.id,
          team_id: team.id,
          transaction_reference: "abc123",
          payment_method: "telr"
        })

      conn = post(conn, panel_visits_visit_path(conn, :move_to_canceled, pending_visit.id))
      assert response(conn, 200)

      refute Postgres.Repo.get(Visits.PendingVisit, pending_visit.id)
      canceled_visit = Postgres.Repo.get(Visits.CanceledVisit, pending_visit.id)

      assert Postgres.Repo.get_by(Visits.Visit.Payment.Refund, payment_id: payment.id)
      assert_called(PaymentsApi.Client.Refund, refund_visit: 3)

      assert canceled_visit
      assert canceled_visit.canceled_by == "doctor"
    end
  end

  describe "GET show" do
    setup [:authenticate_external]

    test "gets the list of visits for specialist", %{
      conn: conn,
      current_external: specialist,
      patient: patient
    } do
      medical_category = SpecialistProfile.Factory.insert(:medical_category)

      {:ok, [specialist_medical_category]} =
        SpecialistProfile.update_medical_categories([medical_category.id], specialist.id)

      _ = SpecialistProfile.Factory.insert(:medical_credentials, specialist_id: specialist.id)

      date = Date.utc_today()
      start_time = Timex.to_unix(date)

      {:ok, team} = Teams.create_team(random_id(), %{})
      :ok = add_to_team(team_id: team.id, specialist_id: specialist.id)

      {:ok, _day_schedule} =
        Visits.DaySchedule.insert_or_update(
          %Visits.DaySchedule{specialist_id: specialist.id, date: date},
          [%{start_time: start_time, visit_type: :ONLINE}],
          []
        )

      cmd = %Visits.Commands.TakeTimeslot{
        specialist_id: specialist.id,
        start_time: start_time,
        patient_id: patient.id,
        chosen_medical_category_id: specialist_medical_category.id,
        visit_type: :ONLINE
      }

      {:ok, pending_visit} = Visits.take_timeslot(cmd)

      {:ok, _payment} =
        Visits.Payments.create(%{
          visit_id: pending_visit.record_id,
          patient_id: patient.id,
          specialist_id: specialist.id,
          team_id: team.id,
          transaction_reference: "abc123",
          payment_method: "telr"
        })

      conn = get(conn, panel_visits_visit_path(conn, :show, pending_visit.id))

      assert response(conn, 200)
    end
  end

  describe "GET uploaded_documents" do
    setup [:authenticate_external]

    test "fetches url of uploaded documents for current specialist", %{
      conn: conn
    } do
      patient_id = 1
      record_id = 1
      url1 = "expample.pdf"
      url2 = "expample_again.png"

      other_specialist_url = "other_specialist.jpg"

      {:ok, _} =
        Visits.UploadedDocuments.create(%{
          record_id: record_id,
          patient_id: patient_id,
          document_url: url1
        })

      {:ok, _} =
        Visits.UploadedDocuments.create(%{
          record_id: record_id,
          patient_id: patient_id,
          document_url: url2
        })

      {:ok, _} =
        Visits.UploadedDocuments.create(%{
          record_id: 2,
          patient_id: 2,
          document_url: other_specialist_url
        })

      conn = get(conn, panel_visits_visit_path(conn, :uploaded_documents, record_id))

      assert %GetUploadedDocuments{
               document_urls: document_urls
             } = proto_response(conn, 200, GetUploadedDocuments)

      assert Enum.any?(document_urls, &(&1 =~ url1))
      assert Enum.any?(document_urls, &(&1 =~ url2))

      refute Enum.any?(document_urls, &(&1 =~ other_specialist_url))
    end
  end

  describe "GET payment_for_visit" do
    setup [:authenticate_external]

    test "returns payment for regular visit", %{
      conn: conn,
      current_external: specialist,
      patient: patient
    } do
      date = Date.utc_today()
      start_time = date |> Timex.to_unix()

      {:ok, _day_schedule} =
        Visits.DaySchedule.insert_or_update(
          %Visits.DaySchedule{specialist_id: specialist.id, date: date},
          [%{start_time: start_time, visit_type: :ONLINE}],
          []
        )

      cmd = %Visits.Commands.TakeTimeslot{
        specialist_id: specialist.id,
        start_time: start_time,
        patient_id: patient.id,
        chosen_medical_category_id: 1,
        visit_type: :ONLINE
      }

      {:ok, %{record_id: record_id}} = Visits.take_timeslot(cmd)

      {:ok, _payment} =
        Visits.Payments.create(%{
          visit_id: record_id,
          patient_id: patient.id,
          specialist_id: specialist.id,
          team_id: nil,
          amount: "1000",
          currency: "AED",
          transaction_reference: "abc123",
          payment_method: "external"
        })

      conn = get(conn, ~p"/panel_api/visits/payment/#{record_id}")

      assert %GetPaymentForVisit{
               amount: "1000",
               currency: "AED",
               record_id: ^record_id,
               payment_method: "in office"
             } = proto_response(conn, 200, GetPaymentForVisit)
    end
  end

  defp add_to_team(opts) do
    :ok = Teams.add_to_team(opts)
    Teams.accept_invitation(opts)
  end

  defp random_id, do: :rand.uniform(1000)
end
