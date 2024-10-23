defmodule Web.Api.Visits.SpecialistCalendarControllerTest do
  use Oban.Testing, repo: Postgres.Repo
  use Web.ConnCase, async: true

  import Mockery.Assertions

  alias Proto.Visits.CreateVisitRequest
  alias Proto.Visits.CreateVisitResponse
  alias Proto.Visits.GetCalendarResponse

  describe "GET show" do
    setup [:authenticate_patient]

    test "returns free timeslots of selected external freelancer", %{conn: conn} do
      doctor = Authentication.Factory.insert(:specialist, type: "EXTERNAL")
      date = ~D[2100-11-15]
      start_time = ~N[2100-11-15T12:00:00] |> Timex.to_unix()

      {:ok, _day_schedule} =
        Visits.DaySchedule.insert_or_update(
          %Visits.DaySchedule{specialist_id: doctor.id, date: date},
          [%{start_time: start_time, visit_type: :ONLINE}],
          []
        )

      params = %{"month" => date |> Timex.to_unix() |> to_string()}
      conn = get(conn, visits_specialist_calendar_path(conn, :show, doctor), params)

      assert %GetCalendarResponse{timeslots: [timeslot]} =
               proto_response(conn, 200, GetCalendarResponse)

      assert timeslot == %Proto.Visits.Timeslot{
               start_time: start_time,
               status: {:free, %Proto.Visits.Timeslot.Free{visit_type: :ONLINE}}
             }
    end
  end

  describe "POST create_visit" do
    setup [:authenticate_patient, :proto_content]

    test "takes timeslot, create payments and returns visit record id", %{
      conn: conn,
      current_patient: %{id: current_patient_id}
    } do
      specialist = Authentication.Factory.insert(:specialist)

      specialist_basic_info =
        SpecialistProfile.Factory.insert(:basic_info, specialist_id: specialist.id)

      %{id: medical_category_id, name: medical_category_name} =
        SpecialistProfile.Factory.insert(:medical_category)

      team = add_to_team(specialist.id)
      basic_info = PatientProfile.Factory.insert(:basic_info, patient_id: current_patient_id)

      date = ~D[2100-11-10]
      start_time = Timex.to_unix(~N[2100-11-10T12:00:00])

      {:ok, _day_schedule} =
        Visits.DaySchedule.insert_or_update(
          %Visits.DaySchedule{specialist_id: specialist.id, date: date},
          [%{start_time: start_time, visit_type: :ONLINE}],
          []
        )

      user_timezone = "Europe/Warsaw"

      proto =
        %Proto.Visits.CreateVisitRequest{
          timeslot_params: %Proto.Visits.TimeslotParams{
            start_time: start_time,
            visit_type: :ONLINE
          },
          chosen_medical_category_id: medical_category_id,
          payments_params: %Proto.Visits.PaymentsParams{
            amount: "1000",
            currency: "USD",
            transaction_reference: "1234",
            payment_method: :TELR |> Proto.Visits.PaymentsParams.PaymentMethod.value()
          },
          user_timezone: user_timezone
        }
        |> CreateVisitRequest.new()
        |> CreateVisitRequest.encode()

      assert %CreateVisitResponse{record_id: record_id} =
               conn
               |> post(
                 visits_specialist_calendar_path(conn, :create_visit, specialist.id),
                 proto
               )
               |> proto_response(200, CreateVisitResponse)

      assert is_number(record_id)

      assert day_schedule =
               Postgres.Repo.get_by(Visits.DaySchedule, %{
                 date: date,
                 free_timeslots: [],
                 free_timeslots_count: 0,
                 specialist_id: specialist.id,
                 taken_timeslots_count: 1
               })

      assert [
               %Visits.TakenTimeslot{
                 patient_id: ^current_patient_id,
                 record_id: ^record_id,
                 start_time: visit_date,
                 visit_type: :ONLINE
               }
             ] = day_schedule.taken_timeslots

      assert %Visits.Visit.Payment{inserted_at: payment_date} =
               Postgres.Repo.get_by(Visits.Visit.Payment, %{
                 specialist_id: specialist.id,
                 team_id: team.id,
                 patient_id: current_patient_id,
                 visit_id: record_id,
                 transaction_reference: "1234",
                 payment_method: :telr
               })

      assert_enqueued(
        worker: Mailers.MailerJobs,
        args: %{
          "type" => "VISIT_BOOKING_CONFIRMATION",
          "patient_email" => basic_info.email,
          "amount" => 1000,
          "currency" => "USD",
          "medical_category_name" => medical_category_name,
          "payment_date" => Mailers.Helpers.humanize_datetime(payment_date, user_timezone),
          "visit_date" => Mailers.Helpers.humanize_datetime(visit_date, user_timezone),
          "specialist_name" =>
            Mailers.Helpers.format_specialist(
              specialist_basic_info.first_name,
              specialist_basic_info.last_name,
              specialist_basic_info.medical_title
            )
        }
      )
    end

    test "takes timeslot, create payments and doesn't send email if payment method is set to external",
         %{
           conn: conn,
           current_patient: %{id: current_patient_id}
         } do
      specialist = Authentication.Factory.insert(:specialist)
      team = add_to_team(specialist.id)
      basic_info = PatientProfile.Factory.insert(:basic_info, patient_id: current_patient_id)

      date = ~D[2100-11-10]
      start_time = Timex.to_unix(~N[2100-11-10T12:00:00])

      {:ok, _day_schedule} =
        Visits.DaySchedule.insert_or_update(
          %Visits.DaySchedule{specialist_id: specialist.id, date: date},
          [%{start_time: start_time, visit_type: :ONLINE}],
          []
        )

      proto =
        %Proto.Visits.CreateVisitRequest{
          timeslot_params: %Proto.Visits.TimeslotParams{
            start_time: start_time,
            visit_type: :ONLINE
          },
          chosen_medical_category_id: 1,
          payments_params: %Proto.Visits.PaymentsParams{
            amount: "1000",
            currency: "USD",
            transaction_reference: "1234",
            payment_method: :EXTERNAL |> Proto.Visits.PaymentsParams.PaymentMethod.value()
          },
          user_timezone: "Europe/Warsaw"
        }
        |> CreateVisitRequest.new()
        |> CreateVisitRequest.encode()

      assert %CreateVisitResponse{record_id: record_id} =
               conn
               |> post(
                 visits_specialist_calendar_path(conn, :create_visit, specialist.id),
                 proto
               )
               |> proto_response(200, CreateVisitResponse)

      assert is_number(record_id)

      assert day_schedule =
               Postgres.Repo.get_by(Visits.DaySchedule, %{
                 date: date,
                 free_timeslots: [],
                 free_timeslots_count: 0,
                 specialist_id: specialist.id,
                 taken_timeslots_count: 1
               })

      assert [
               %Visits.TakenTimeslot{
                 patient_id: ^current_patient_id,
                 record_id: ^record_id,
                 visit_type: :ONLINE
               }
             ] = day_schedule.taken_timeslots

      assert Postgres.Repo.get_by(Visits.Visit.Payment, %{
               specialist_id: specialist.id,
               team_id: team.id,
               patient_id: current_patient_id,
               visit_id: record_id,
               transaction_reference: "1234",
               payment_method: :external
             })

      refute_enqueued(
        worker: Mailers.MailerJobs,
        args: %{
          "type" => "VISIT_BOOKING_CONFIRMATION",
          "patient_email" => basic_info.email,
          "amount" => 1000,
          "currency" => "USD"
        }
      )
    end
  end

  describe "POST create_us_board_visit" do
    setup [:authenticate_patient, :proto_content]

    test "takes timeslot, returns visit record id, record type is US_BOARD", %{
      conn: conn,
      current_patient: %{id: current_patient_id}
    } do
      %{id: specialist_id, email: specialist_email} = Authentication.Factory.insert(:specialist)

      date = ~D[2100-11-10]
      start_time = Timex.to_unix(~N[2100-11-10T12:00:00])

      params =
        Visits.Factory.second_opinion_request_default_params(%{
          patient_id: current_patient_id,
          status: :opinion_submitted,
          specialist_opinion: "Get better"
        })

      {:ok, %{id: request_id, patient_email: request_patient_email}} =
        Visits.request_us_board_second_opinion(params)

      assert_called(PushNotifications.Message, :send, [
        %PushNotifications.Message.USBoardRequestConfirmation{
          send_to_patient_id: ^current_patient_id,
          us_board_request_id: ^request_id
        }
      ])

      assert_enqueued(worker: Mailers.MailerJobs, args: %{"type" => "NEW_US_BOARD_REQUEST"})

      assert_enqueued(
        worker: Mailers.MailerJobs,
        args: %{
          "type" => "PATIENT_US_BOARD_REQUEST_CONFIRMATION",
          "patient_email" => request_patient_email,
          "us_board_request_id" => request_id
        }
      )

      Oban.drain_queue(queue: :mailers)

      _medical_category =
        SpecialistProfile.Factory.insert(:medical_category, name: "U.S Board Second Opinion")

      {:ok, _day_schedule} =
        Visits.DaySchedule.insert_or_update(
          %Visits.DaySchedule{specialist_id: specialist_id, date: date},
          [%{start_time: start_time, visit_type: :US_BOARD}],
          []
        )

      proto =
        %Proto.Visits.CreateUsBoardVisitRequest{
          timeslot_params: %Proto.Visits.TimeslotParams{
            start_time: start_time,
            visit_type: :US_BOARD
          },
          us_board_request_id: request_id
        }
        |> CreateVisitRequest.new()
        |> CreateVisitRequest.encode()

      assert %CreateVisitResponse{record_id: record_id} =
               conn
               |> post(
                 visits_specialist_calendar_path(conn, :create_us_board_visit, specialist_id),
                 proto
               )
               |> proto_response(200, CreateVisitResponse)

      assert is_number(record_id)

      assert day_schedule =
               Postgres.Repo.get_by(Visits.DaySchedule, %{
                 date: date,
                 free_timeslots: [],
                 free_timeslots_count: 0,
                 specialist_id: specialist_id,
                 taken_timeslots_count: 1
               })

      assert [
               %Visits.TakenTimeslot{
                 patient_id: ^current_patient_id,
                 record_id: ^record_id
               }
             ] = day_schedule.taken_timeslots

      assert %{status: :call_scheduled} =
               Postgres.Repo.get(Visits.USBoard.SecondOpinionRequest, request_id)

      assert_enqueued(
        worker: Mailers.MailerJobs,
        args: %{
          "type" => "PATIENT_SCHEDULED_US_BOARD_CALL",
          "specialist_email" => specialist_email
        }
      )

      Oban.drain_queue(queue: :mailers)

      assert %{
               type: :US_BOARD,
               us_board_request_id: ^request_id,
               with_specialist_id: ^specialist_id
             } = Postgres.Repo.get(EMR.PatientRecords.PatientRecord, record_id)

      assert {:ok,
              %Visits.USBoard.SecondOpinionRequestPayment{
                price: %{amount: 499, currency: :USD},
                visit_id: ^record_id
              }} =
               Visits.fetch_payment_by_record_and_patient_id(record_id, current_patient_id)
    end
  end

  defp add_to_team(specialist_id) do
    {:ok, team} = Teams.create_team(specialist_id, %{})
    :ok = Teams.add_to_team(team_id: team.id, specialist_id: specialist_id)
    Teams.accept_invitation(team_id: team.id, specialist_id: specialist_id)

    team
  end
end
