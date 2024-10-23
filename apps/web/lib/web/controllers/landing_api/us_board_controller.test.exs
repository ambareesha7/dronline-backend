defmodule Web.LandingApi.LandingApi.USBoardControllerTest do
  use Oban.Testing, repo: Postgres.Repo
  use Web.ConnCase, async: true

  @patient_email "patient@email.com"
  @patient_description "I'm sick"

  setup [:proto_content]

  describe "request_second_opinion" do
    test "creates US board request in DB", %{conn: conn} do
      proto =
        %Proto.Visits.LandingRequestUSBoardSecondOpinionRequest{
          patient_description: @patient_description,
          patient_email: @patient_email,
          files: [%{path: "/file.com"}],
          phone_number: "123123123",
          first_name: "LeBron",
          last_name: "James"
        }
        |> Proto.Visits.LandingRequestUSBoardSecondOpinionRequest.encode()

      assert %Proto.Visits.LandingRequestUSBoardSecondOpinionResponse{
               payment_url: payment_url,
               second_opinion_request_id: second_opinion_request_id
             } =
               conn
               |> post(landing_us_board_path(conn, :request_second_opinion), proto)
               |> proto_response(200, Proto.Visits.LandingRequestUSBoardSecondOpinionResponse)

      assert_enqueued(worker: Mailers.MailerJobs, args: %{"type" => "NEW_US_BOARD_REQUEST"})

      assert %{id: request_id, files: files} =
               Postgres.Repo.get_by(Visits.USBoard.SecondOpinionRequest, %{
                 patient_email: @patient_email,
                 status: :landing_payment_pending,
                 patient_description: @patient_description
               })

      assert payment_url == "https://secure.telr.com/gateway/process.html?o=#{request_id}"
      assert second_opinion_request_id == request_id

      assert [
               %Visits.USBoard.SecondOpinionRequest.File{
                 path: "/file.com"
               }
             ] = files

      Oban.drain_queue(queue: :mailers)
    end
  end

  describe "confirm_second_opinion_payment" do
    test "creates US board payment in DB, changes status to landing_booking and sends confirmation email",
         %{conn: conn} do
      {:ok, %{us_board_request_id: us_board_request_id, payment_url: _payment_url}} =
        Visits.request_second_opinion_from_landing(%{
          patient_description: @patient_description,
          patient_email: @patient_email,
          files: [%{path: "/file.com"}],
          phone_number: "123123123",
          first_name: "LeBron",
          last_name: "James",
          status: :landing_payment_pending,
          host: conn.host
        })

      proto =
        %Proto.Visits.LandingConfirmUSBoardSecondOpinionRequest{
          second_opinion_request_id: us_board_request_id,
          transaction_reference: "1234"
        }
        |> Proto.Visits.LandingConfirmUSBoardSecondOpinionRequest.encode()

      conn =
        post(
          conn,
          landing_us_board_path(conn, :confirm_second_opinion_payment),
          proto
        )

      assert response(conn, 201)

      assert Postgres.Repo.get_by(Visits.USBoard.SecondOpinionRequest, %{
               id: us_board_request_id,
               patient_email: @patient_email,
               status: :landing_booking,
               patient_description: @patient_description
             })

      assert payment =
               Postgres.Repo.get_by(Visits.USBoard.SecondOpinionRequestPayment, %{
                 transaction_reference: "1234",
                 payment_method: :telr,
                 us_board_second_opinion_request_id: us_board_request_id
               })

      assert payment.price == %Money{amount: 499, currency: :USD}

      assert_enqueued(
        worker: Mailers.MailerJobs,
        args: %{
          "type" => "PATIENT_US_BOARD_REQUEST_CONFIRMATION",
          "patient_email" => @patient_email,
          "us_board_request_id" => us_board_request_id
        }
      )

      Oban.drain_queue(queue: :mailers)
    end

    test "test email -> creates US board payment in DB, changes status to landing_booking and sends confirmation email",
         %{conn: conn} do
      test_email = "ravin@dronline.ai"

      {:ok, %{us_board_request_id: us_board_request_id, payment_url: _payment_url}} =
        Visits.request_second_opinion_from_landing(%{
          patient_description: @patient_description,
          patient_email: test_email,
          files: [%{path: "/file.com"}],
          phone_number: "123123123",
          first_name: "LeBron",
          last_name: "James",
          status: :landing_payment_pending,
          host: conn.host
        })

      proto =
        %Proto.Visits.LandingConfirmUSBoardSecondOpinionRequest{
          second_opinion_request_id: us_board_request_id,
          transaction_reference: "1234"
        }
        |> Proto.Visits.LandingConfirmUSBoardSecondOpinionRequest.encode()

      conn =
        post(
          conn,
          landing_us_board_path(conn, :confirm_second_opinion_payment),
          proto
        )

      assert response(conn, 201)

      assert Postgres.Repo.get_by(Visits.USBoard.SecondOpinionRequest, %{
               id: us_board_request_id,
               patient_email: test_email,
               status: :landing_booking,
               patient_description: @patient_description
             })

      assert payment =
               Postgres.Repo.get_by(Visits.USBoard.SecondOpinionRequestPayment, %{
                 transaction_reference: "1234",
                 payment_method: :telr,
                 us_board_second_opinion_request_id: us_board_request_id
               })

      assert payment.price == %Money{amount: 1, currency: :USD}

      assert_enqueued(
        worker: Mailers.MailerJobs,
        args: %{
          "type" => "PATIENT_US_BOARD_REQUEST_CONFIRMATION",
          "patient_email" => test_email,
          "us_board_request_id" => us_board_request_id
        }
      )

      Oban.drain_queue(queue: :mailers)
    end
  end

  describe "fill_contact_form" do
    test "creates US board request in DB", %{conn: conn} do
      proto =
        %Proto.Visits.LandingUSBoardContactFormRequest{
          patient_description: @patient_description,
          patient_email: @patient_email
        }
        |> Proto.Visits.LandingUSBoardContactFormRequest.encode()

      conn =
        post(
          conn,
          landing_us_board_path(conn, :fill_contact_form),
          proto
        )

      assert response(conn, 201)

      assert %{id: request_id} =
               Postgres.Repo.get_by(Visits.USBoard.SecondOpinionRequest, %{
                 patient_email: @patient_email,
                 status: :landing_form,
                 patient_description: @patient_description
               })

      assert_enqueued(worker: Mailers.MailerJobs, args: %{"type" => "NEW_US_BOARD_REQUEST"})

      assert_enqueued(
        worker: Mailers.MailerJobs,
        args: %{
          "type" => "PATIENT_US_BOARD_REQUEST_CONFIRMATION",
          "patient_email" => @patient_email,
          "us_board_request_id" => request_id
        }
      )

      Oban.drain_queue(queue: :mailers)
    end
  end
end
