defmodule Web.Api.Visits.USBoardControllerTest do
  use Oban.Testing, repo: Postgres.Repo
  use Web.ConnCase, async: true

  import Mockery.Assertions

  alias Proto.Visits.RequestUSBoardSecondOpinionRequest
  alias Proto.Visits.RequestUSBoardSecondOpinionResponse
  alias Proto.Visits.USBoardSecondOpinionRequestResponse
  alias Proto.Visits.USBoardSecondOpinionRequestsResponse

  describe "GET fetch_patient_second_opinion_requests" do
    setup [:authenticate_patient]

    test "returns all second opinions requests for patient", %{
      conn: conn,
      current_patient: %{id: current_patient_id}
    } do
      %{id: other_patient_id} = PatientProfile.Factory.insert(:patient)

      patient_params =
        Visits.Factory.second_opinion_request_default_params(%{
          patient_id: current_patient_id,
          patient_email: "patient@email.com",
          transaction_reference: "1234"
        })

      other_params =
        Visits.Factory.second_opinion_request_default_params(%{
          patient_id: other_patient_id,
          patient_description: "Help me!",
          transaction_reference: "5678"
        })

      {:ok, %{id: request_id, patient_email: request_patient_email}} =
        Visits.request_us_board_second_opinion(patient_params)

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

      {:ok, %{id: other_request_id, patient_email: other_request_patient_email}} =
        Visits.request_us_board_second_opinion(other_params)

      assert_enqueued(worker: Mailers.MailerJobs, args: %{"type" => "NEW_US_BOARD_REQUEST"})

      assert_called(PushNotifications.Message, :send, [
        %PushNotifications.Message.USBoardRequestConfirmation{
          send_to_patient_id: ^other_patient_id,
          us_board_request_id: ^other_request_id
        }
      ])

      assert_enqueued(
        worker: Mailers.MailerJobs,
        args: %{
          "type" => "PATIENT_US_BOARD_REQUEST_CONFIRMATION",
          "patient_email" => other_request_patient_email,
          "us_board_request_id" => other_request_id
        }
      )

      Oban.drain_queue(queue: :mailers)

      assert %USBoardSecondOpinionRequestsResponse{
               us_board_second_opinion_requests: [
                 %Proto.Visits.USBoardSecondOpinionRequest{
                   id: ^request_id,
                   specialist_id: 0,
                   patient_id: ^current_patient_id,
                   visit_id: "",
                   patient_description: "I'm sick",
                   specialist_opinion: "",
                   patient_email: "patient@email.com",
                   status: :REQUESTED,
                   files: [%Proto.Visits.USBoardFilesToDownload{download_url: download_url}],
                   payments_params: %Proto.Visits.PaymentsParams{
                     amount: "499",
                     currency: "USD",
                     transaction_reference: "1234",
                     payment_method: :TELR
                   }
                 }
               ]
             } =
               conn
               |> get(visits_us_board_path(conn, :index_us_board_second_opinion))
               |> proto_response(200, USBoardSecondOpinionRequestsResponse)

      assert download_url =~ "https://storage.googleapis.com/file.pdf"
    end
  end

  describe "us_board_second_opinion" do
    setup [:authenticate_patient]

    test "show second opinion request by id", %{conn: conn} do
      %{id: patient_id} = PatientProfile.Factory.insert(:patient)

      {:ok, %{id: request_id, patient_email: request_patient_email}} =
        %{patient_id: patient_id, transaction_reference: "1234"}
        |> Visits.Factory.second_opinion_request_default_params()
        |> Visits.request_us_board_second_opinion()

      assert_called(PushNotifications.Message, :send, [
        %PushNotifications.Message.USBoardRequestConfirmation{
          send_to_patient_id: ^patient_id,
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

      assert %USBoardSecondOpinionRequestResponse{
               us_board_second_opinion_request: %{
                 id: ^request_id,
                 specialist_id: 0,
                 patient_id: ^patient_id,
                 visit_id: "",
                 patient_description: "I'm sick",
                 specialist_opinion: "",
                 patient_email: "patient@example.com",
                 status: :REQUESTED,
                 files: [%Proto.Visits.USBoardFilesToDownload{download_url: download_url}],
                 payments_params: %Proto.Visits.PaymentsParams{
                   amount: "499",
                   currency: "USD",
                   transaction_reference: "1234",
                   payment_method: :TELR
                 }
               }
             } =
               conn
               |> get(visits_us_board_path(conn, :us_board_second_opinion, request_id))
               |> proto_response(200, USBoardSecondOpinionRequestResponse)

      assert download_url =~ "https://storage.googleapis.com/file.pdf"
    end
  end

  describe "POST request_us_board_second_opinion" do
    setup [:proto_content, :authenticate_patient]

    test "creates US board second opinion request and payment", %{
      conn: conn,
      current_patient: %{id: current_patient_id}
    } do
      patient_email = "patient@email.com"

      proto =
        %{
          patient_description: "I'm sick",
          patient_email: patient_email,
          files: [%{path: "/file.com"}],
          payments_params: %Proto.Visits.PaymentsParams{
            transaction_reference: "1234"
          }
        }
        |> RequestUSBoardSecondOpinionRequest.new()
        |> RequestUSBoardSecondOpinionRequest.encode()

      assert %RequestUSBoardSecondOpinionResponse{
               id: request_id
             } =
               conn
               |> post(visits_us_board_path(conn, :request_us_board_second_opinion), proto)
               |> proto_response(200, RequestUSBoardSecondOpinionResponse)

      assert %{
               patient_id: ^current_patient_id,
               patient_description: "I'm sick",
               patient_email: ^patient_email,
               status: :requested,
               files: [%Visits.USBoard.SecondOpinionRequest.File{path: "/file.com"}],
               us_board_second_opinion_request_payment:
                 %Visits.USBoard.SecondOpinionRequestPayment{
                   patient_id: ^current_patient_id,
                   transaction_reference: "1234",
                   payment_method: :telr,
                   price: %Money{amount: 499, currency: :USD},
                   us_board_second_opinion_request_id: ^request_id
                 }
             } =
               Visits.USBoard.SecondOpinionRequest
               |> Postgres.Repo.get(request_id)
               |> Postgres.Repo.preload(:us_board_second_opinion_request_payment)

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
          "patient_email" => patient_email,
          "us_board_request_id" => request_id
        }
      )

      Oban.drain_queue(queue: :mailers)
    end

    test "test email -> creates US board second opinion request and payment", %{
      conn: conn,
      current_patient: %{id: current_patient_id}
    } do
      patient_email = "ravin@dronline.ai"

      proto =
        %{
          patient_description: "I'm sick",
          patient_email: patient_email,
          files: [%{path: "/file.com"}],
          payments_params: %Proto.Visits.PaymentsParams{
            transaction_reference: "1234"
          }
        }
        |> RequestUSBoardSecondOpinionRequest.new()
        |> RequestUSBoardSecondOpinionRequest.encode()

      assert %RequestUSBoardSecondOpinionResponse{
               id: request_id
             } =
               conn
               |> post(visits_us_board_path(conn, :request_us_board_second_opinion), proto)
               |> proto_response(200, RequestUSBoardSecondOpinionResponse)

      assert %{
               patient_id: ^current_patient_id,
               patient_description: "I'm sick",
               patient_email: ^patient_email,
               status: :requested,
               files: [%Visits.USBoard.SecondOpinionRequest.File{path: "/file.com"}],
               us_board_second_opinion_request_payment:
                 %Visits.USBoard.SecondOpinionRequestPayment{
                   patient_id: ^current_patient_id,
                   transaction_reference: "1234",
                   payment_method: :telr,
                   price: %Money{amount: 1, currency: :USD},
                   us_board_second_opinion_request_id: ^request_id
                 }
             } =
               Visits.USBoard.SecondOpinionRequest
               |> Postgres.Repo.get(request_id)
               |> Postgres.Repo.preload(:us_board_second_opinion_request_payment)

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
          "patient_email" => patient_email,
          "us_board_request_id" => request_id
        }
      )

      Oban.drain_queue(queue: :mailers)
    end
  end
end
