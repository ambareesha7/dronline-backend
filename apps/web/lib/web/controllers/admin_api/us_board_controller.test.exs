defmodule Web.AdminApi.USBoardControllerTest do
  use Oban.Testing, repo: Postgres.Repo
  use Web.ConnCase, async: true

  import Mockery.Assertions

  alias Postgres.Repo
  alias Proto.AdminPanel.FetchUSBoardSpecialistsResponse
  alias Proto.AdminPanel.USBoardAssignSpecialistRequest
  alias Proto.Visits.USBoardSecondOpinionRequestResponse
  alias Proto.Visits.USBoardSecondOpinionRequestsResponse
  alias Visits.USBoard.SecondOpinionRequest

  setup [:authenticate_admin]

  describe "fetch_requests" do
    test "returns all requests", %{conn: conn} do
      %{id: patient_1_id} = PatientProfile.Factory.insert(:patient)

      %{id: patient_2_id} = PatientProfile.Factory.insert(:patient)

      other_params =
        %{
          patient_id: patient_2_id,
          patient_description: "Help me!",
          patient_email: "other@example.com",
          files: [%{path: "/file2.com"}],
          status: "requested",
          transaction_reference: "5678",
          payment_method: "telr"
        }

      {:ok, %{id: request_1_id, patient_email: request_1_patient_email}} =
        insert_us_board_request(patient_1_id)

      assert_called(PushNotifications.Message, :send, [
        %PushNotifications.Message.USBoardRequestConfirmation{
          send_to_patient_id: ^patient_1_id,
          us_board_request_id: ^request_1_id
        }
      ])

      assert_enqueued(worker: Mailers.MailerJobs, args: %{"type" => "NEW_US_BOARD_REQUEST"})

      assert_enqueued(
        worker: Mailers.MailerJobs,
        args: %{
          "type" => "PATIENT_US_BOARD_REQUEST_CONFIRMATION",
          "patient_email" => request_1_patient_email,
          "us_board_request_id" => request_1_id
        }
      )

      Oban.drain_queue(queue: :mailers)

      {:ok, %{id: request_2_id, patient_email: request_2_patient_email}} =
        Visits.request_us_board_second_opinion(other_params)

      assert_enqueued(worker: Mailers.MailerJobs, args: %{"type" => "NEW_US_BOARD_REQUEST"})

      assert_enqueued(
        worker: Mailers.MailerJobs,
        args: %{
          "type" => "PATIENT_US_BOARD_REQUEST_CONFIRMATION",
          "patient_email" => request_2_patient_email,
          "us_board_request_id" => request_2_id
        }
      )

      Oban.drain_queue(queue: :mailers)

      assert_called(PushNotifications.Message, :send, [
        %PushNotifications.Message.USBoardRequestConfirmation{
          send_to_patient_id: ^patient_2_id,
          us_board_request_id: ^request_2_id
        }
      ])

      assert %USBoardSecondOpinionRequestsResponse{
               us_board_second_opinion_requests: requests
             } =
               conn
               |> get(admin_us_board_path(conn, :fetch_requests))
               |> proto_response(200, USBoardSecondOpinionRequestsResponse)

      assert [
               %Proto.Visits.USBoardSecondOpinionRequest{
                 id: ^request_2_id,
                 specialist_id: 0,
                 patient_id: ^patient_2_id,
                 visit_id: "",
                 patient_description: "Help me!",
                 specialist_opinion: "",
                 patient_email: "other@example.com",
                 status: :REQUESTED,
                 files: [%Proto.Visits.USBoardFilesToDownload{download_url: download_url_2}],
                 payments_params: %Proto.Visits.PaymentsParams{
                   amount: "499",
                   currency: "USD",
                   transaction_reference: "5678",
                   payment_method: :TELR
                 }
               },
               %Proto.Visits.USBoardSecondOpinionRequest{
                 id: ^request_1_id,
                 specialist_id: 0,
                 patient_id: ^patient_1_id,
                 visit_id: "",
                 patient_description: "I'm sick",
                 specialist_opinion: "",
                 patient_email: "patient@example.com",
                 status: :REQUESTED,
                 files: [%Proto.Visits.USBoardFilesToDownload{download_url: download_url_1}],
                 payments_params: %Proto.Visits.PaymentsParams{
                   amount: "499",
                   currency: "USD",
                   transaction_reference: "1234",
                   payment_method: :TELR
                 }
               }
             ] = requests

      assert download_url_1 =~ "https://storage.googleapis.com/file.pdf"
      assert download_url_2 =~ "https://storage.googleapis.com/file2.com"
    end

    test "fetch requests with assigned specialists in descending inserted_at order", %{conn: conn} do
      %{id: patient_id} = PatientProfile.Factory.insert(:patient)

      %{id: specialist_1_id, email: specialist_1_email} =
        Authentication.Factory.insert(:verified_specialist)

      %{id: specialist_2_id, email: specialist_2_email} =
        Authentication.Factory.insert(:verified_specialist)

      SpecialistProfile.Factory.insert(:basic_info, specialist_id: specialist_1_id)
      SpecialistProfile.Factory.insert(:basic_info, specialist_id: specialist_2_id)

      {:ok, %{id: request_1_id, patient_email: request_1_patient_email}} =
        insert_us_board_request(patient_id)

      assert_called(PushNotifications.Message, :send, [
        %PushNotifications.Message.USBoardRequestConfirmation{
          send_to_patient_id: ^patient_id,
          us_board_request_id: ^request_1_id
        }
      ])

      assert_enqueued(worker: Mailers.MailerJobs, args: %{"type" => "NEW_US_BOARD_REQUEST"})

      assert_enqueued(
        worker: Mailers.MailerJobs,
        args: %{
          "type" => "PATIENT_US_BOARD_REQUEST_CONFIRMATION",
          "patient_email" => request_1_patient_email,
          "us_board_request_id" => request_1_id
        }
      )

      Oban.drain_queue(queue: :mailers)

      {:ok, %{id: request_2_id, patient_email: request_2_patient_email}} =
        insert_us_board_request(patient_id)

      assert_enqueued(worker: Mailers.MailerJobs, args: %{"type" => "NEW_US_BOARD_REQUEST"})

      assert_enqueued(
        worker: Mailers.MailerJobs,
        args: %{
          "type" => "PATIENT_US_BOARD_REQUEST_CONFIRMATION",
          "patient_email" => request_2_patient_email,
          "us_board_request_id" => request_2_id
        }
      )

      assert_called(PushNotifications.Message, :send, [
        %PushNotifications.Message.USBoardRequestConfirmation{
          send_to_patient_id: ^patient_id,
          us_board_request_id: ^request_2_id
        }
      ])

      Oban.drain_queue(queue: :mailers)

      Visits.assign_specialist_to_second_opinion_request(specialist_1_id, request_1_id)

      assert_enqueued(
        worker: Mailers.MailerJobs,
        args: %{
          "type" => "SPECIALIST_ASSIGNED_TO_US_BOARD_REQUEST",
          "specialist_email" => specialist_1_email
        }
      )

      Oban.drain_queue(queue: :mailers)

      Visits.assign_specialist_to_second_opinion_request(specialist_2_id, request_2_id)

      assert_enqueued(
        worker: Mailers.MailerJobs,
        args: %{
          "type" => "SPECIALIST_ASSIGNED_TO_US_BOARD_REQUEST",
          "specialist_email" => specialist_2_email
        }
      )

      Oban.drain_queue(queue: :mailers)

      assert %USBoardSecondOpinionRequestsResponse{
               us_board_second_opinion_requests: [
                 %Proto.Visits.USBoardSecondOpinionRequest{
                   id: ^request_2_id,
                   specialist_id: ^specialist_2_id,
                   patient_id: ^patient_id
                 },
                 %Proto.Visits.USBoardSecondOpinionRequest{
                   id: ^request_1_id,
                   specialist_id: ^specialist_1_id,
                   patient_id: ^patient_id
                 }
               ]
             } =
               conn
               |> get(admin_us_board_path(conn, :fetch_requests))
               |> proto_response(200, USBoardSecondOpinionRequestsResponse)

      ## reassigns specialist and sends email

      Visits.assign_specialist_to_second_opinion_request(specialist_2_id, request_1_id)

      assert_enqueued(
        worker: Mailers.MailerJobs,
        args: %{
          "type" => "SPECIALIST_ASSIGNED_TO_US_BOARD_REQUEST",
          "specialist_email" => specialist_2_email
        }
      )

      Oban.drain_queue(queue: :mailers)

      assert %USBoardSecondOpinionRequestsResponse{
               us_board_second_opinion_requests: [
                 %Proto.Visits.USBoardSecondOpinionRequest{
                   id: ^request_2_id,
                   specialist_id: ^specialist_2_id,
                   patient_id: ^patient_id
                 },
                 %Proto.Visits.USBoardSecondOpinionRequest{
                   id: ^request_1_id,
                   specialist_id: ^specialist_2_id,
                   patient_id: ^patient_id
                 }
               ]
             } =
               conn
               |> get(admin_us_board_path(conn, :fetch_requests))
               |> proto_response(200, USBoardSecondOpinionRequestsResponse)
    end

    test "fetch requests after rejecting by a specialist", %{conn: conn} do
      %{id: patient_id} = PatientProfile.Factory.insert(:patient)
      _patient_basic_info = PatientProfile.Factory.insert(:basic_info, patient_id: patient_id)

      specialist_first_name = "Joe"
      specialist_last_name = "Doe"
      %{id: specialist_id} = Authentication.Factory.insert(:verified_specialist)

      _specialist_basic_info =
        SpecialistProfile.Factory.insert(:basic_info,
          specialist_id: specialist_id,
          first_name: specialist_first_name,
          last_name: specialist_last_name
        )

      {:ok, %{id: request_id}} = insert_us_board_request(patient_id)

      assert_called(PushNotifications.Message, :send, [
        %PushNotifications.Message.USBoardRequestConfirmation{
          send_to_patient_id: ^patient_id,
          us_board_request_id: ^request_id
        }
      ])

      ## assign specialist
      Visits.USBoard.assign_specialist_to_second_opinion_request(specialist_id, request_id)

      ## reject by specialist
      Visits.reject_us_board_second_opinion(specialist_id, request_id)

      assert %USBoardSecondOpinionRequestsResponse{
               us_board_second_opinion_requests: [
                 %Proto.Visits.USBoardSecondOpinionRequest{
                   id: ^request_id,
                   specialist_id: 0,
                   patient_id: ^patient_id,
                   specialists_history: [
                     %{
                       specialist_id: ^specialist_id,
                       specialist_first_name: ^specialist_first_name,
                       specialist_last_name: ^specialist_last_name,
                       accepted_at: nil,
                       rejected_at: rejected_at,
                       assigned_at: assigned_at
                     }
                   ]
                 }
               ]
             } =
               conn
               |> get(admin_us_board_path(conn, :fetch_requests))
               |> proto_response(200, USBoardSecondOpinionRequestsResponse)

      assert rejected_at
      assert assigned_at
    end

    test "fetch requests from landing page form", %{conn: conn} do
      {:ok, %{id: request_1_id, patient_email: request_1_patient_email}} =
        %{
          patient_description: "Morning!",
          patient_email: "email@example.com",
          files: [%{path: "/file.pdf"}],
          phone_number: "123123123",
          first_name: "LeBron",
          last_name: "James",
          status: :landing_form,
          host: conn.host
        }
        |> Visits.request_second_opinion_from_landing()

      assert %USBoardSecondOpinionRequestsResponse{
               us_board_second_opinion_requests: [
                 %Proto.Visits.USBoardSecondOpinionRequest{
                   id: ^request_1_id,
                   specialist_id: 0,
                   patient_id: 0,
                   visit_id: "",
                   patient_description: "Morning!",
                   specialist_opinion: "",
                   patient_email: ^request_1_patient_email,
                   status: :LANDING_FORM,
                   payments_params: %Proto.Visits.PaymentsParams{
                     amount: "",
                     currency: "",
                     transaction_reference: "",
                     payment_method: :EXTERNAL
                   }
                 }
               ]
             } =
               conn
               |> get(admin_us_board_path(conn, :fetch_requests))
               |> proto_response(200, USBoardSecondOpinionRequestsResponse)
    end
  end

  describe "fetch_request" do
    test "fetch second opinion request", %{conn: conn} do
      %{id: patient_1_id} = PatientProfile.Factory.insert(:patient)

      {:ok, %{id: request_1_id, patient_email: request_1_patient_email}} =
        insert_us_board_request(patient_1_id)

      assert_called(PushNotifications.Message, :send, [
        %PushNotifications.Message.USBoardRequestConfirmation{
          send_to_patient_id: ^patient_1_id,
          us_board_request_id: ^request_1_id
        }
      ])

      assert_enqueued(worker: Mailers.MailerJobs, args: %{"type" => "NEW_US_BOARD_REQUEST"})

      assert_enqueued(
        worker: Mailers.MailerJobs,
        args: %{
          "type" => "PATIENT_US_BOARD_REQUEST_CONFIRMATION",
          "patient_email" => request_1_patient_email,
          "us_board_request_id" => request_1_id
        }
      )

      Oban.drain_queue(queue: :mailers)

      assert %USBoardSecondOpinionRequestResponse{
               us_board_second_opinion_request: %{
                 id: ^request_1_id,
                 specialist_id: 0,
                 patient_id: ^patient_1_id,
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
                 },
                 specialists_history: []
               }
             } =
               conn
               |> get(admin_us_board_path(conn, :fetch_request, request_1_id))
               |> proto_response(200, USBoardSecondOpinionRequestResponse)

      assert download_url =~ "https://storage.googleapis.com/file.pdf"
    end

    test "returns specialist history", %{conn: conn} do
      %{id: patient_1_id} = PatientProfile.Factory.insert(:patient)

      {:ok, %{id: request_id}} =
        insert_us_board_request(patient_1_id)

      specialist_first_name = "Joe"
      specialist_last_name = "Doe"
      %{id: specialist_id} = Authentication.Factory.insert(:verified_specialist)

      _specialist_basic_info =
        SpecialistProfile.Factory.insert(:basic_info,
          specialist_id: specialist_id,
          first_name: specialist_first_name,
          last_name: specialist_last_name
        )

      ## assign specialist
      Visits.USBoard.assign_specialist_to_second_opinion_request(specialist_id, request_id)

      ## reject by specialist
      Visits.reject_us_board_second_opinion(specialist_id, request_id)

      assert %USBoardSecondOpinionRequestResponse{
               us_board_second_opinion_request: %{
                 id: ^request_id,
                 specialist_id: 0,
                 patient_id: ^patient_1_id,
                 patient_email: "patient@example.com",
                 status: :REJECTED,
                 specialists_history: [
                   %{
                     specialist_id: ^specialist_id,
                     rejected_at: rejected_at,
                     accepted_at: nil,
                     assigned_at: assigned_at,
                     specialist_first_name: ^specialist_first_name,
                     specialist_last_name: ^specialist_last_name
                   }
                 ]
               }
             } =
               conn
               |> get(admin_us_board_path(conn, :fetch_request, request_id))
               |> proto_response(200, USBoardSecondOpinionRequestResponse)

      assert rejected_at
      assert assigned_at
    end
  end

  describe "fetch_us_board_specialists" do
    test "fetch all specialist serving US board services and its subcategories", %{conn: conn} do
      %{id: specialist_1_id} = Authentication.Factory.insert(:verified_specialist)
      %{id: specialist_2_id} = Authentication.Factory.insert(:verified_specialist)
      %{id: specialist_3_id} = Authentication.Factory.insert(:verified_specialist)

      _basic_info = SpecialistProfile.Factory.insert(:basic_info, specialist_id: specialist_1_id)
      _basic_info = SpecialistProfile.Factory.insert(:basic_info, specialist_id: specialist_2_id)
      _basic_info = SpecialistProfile.Factory.insert(:basic_info, specialist_id: specialist_3_id)

      us_board_medical_category =
        SpecialistProfile.Factory.insert(:medical_category, name: "U.S Board Second Opinion")

      allergology_medical_category =
        SpecialistProfile.Factory.insert(:medical_category, name: "Allergology")

      surgery_medical_category =
        SpecialistProfile.Factory.insert(:medical_category,
          name: "Neuro Surgery",
          parent_category_id: us_board_medical_category.id
        )

      SpecialistProfile.update_medical_categories([us_board_medical_category.id], specialist_1_id)

      SpecialistProfile.update_medical_categories(
        [allergology_medical_category.id],
        specialist_2_id
      )

      SpecialistProfile.update_medical_categories(
        [surgery_medical_category.id],
        specialist_3_id
      )

      assert %FetchUSBoardSpecialistsResponse{
               specialists:
                 [%Proto.AdminPanel.USBoardSpecialist{}, %Proto.AdminPanel.USBoardSpecialist{}] =
                   specialists
             } =
               conn
               |> get(admin_us_board_path(conn, :fetch_us_board_specialists))
               |> proto_response(200, FetchUSBoardSpecialistsResponse)

      assert Enum.count(specialists) == 2

      specialists_ids = Enum.map(specialists, & &1.specialist_id)

      assert Enum.member?(specialists_ids, specialist_1_id)
      assert Enum.member?(specialists_ids, specialist_3_id)
    end
  end

  describe "assign_specialist" do
    setup [:proto_content]

    test "assigns specialist to second opinion request", %{conn: conn} do
      %{id: patient_1_id} = PatientProfile.Factory.insert(:patient)

      %{id: specialist_1_id, email: specialist_1_email} =
        Authentication.Factory.insert(:verified_specialist)

      {:ok, %{id: request_1_id, patient_email: request_1_patient_email}} =
        insert_us_board_request(patient_1_id)

      assert_called(PushNotifications.Message, :send, [
        %PushNotifications.Message.USBoardRequestConfirmation{
          send_to_patient_id: ^patient_1_id,
          us_board_request_id: ^request_1_id
        }
      ])

      assert_enqueued(worker: Mailers.MailerJobs, args: %{"type" => "NEW_US_BOARD_REQUEST"})

      assert_enqueued(
        worker: Mailers.MailerJobs,
        args: %{
          "type" => "PATIENT_US_BOARD_REQUEST_CONFIRMATION",
          "patient_email" => request_1_patient_email,
          "us_board_request_id" => request_1_id
        }
      )

      Oban.drain_queue(queue: :mailers)

      proto =
        %{
          specialist_id: specialist_1_id,
          request_id: request_1_id
        }
        |> USBoardAssignSpecialistRequest.new()
        |> USBoardAssignSpecialistRequest.encode()

      assert conn
             |> post(admin_us_board_path(conn, :assign_specialist), proto)
             |> response(201)

      assert assigned_specialist =
               Repo.get_by(Admin.USBoard.SecondOpinionRequest.AssignedSpecialist,
                 specialist_id: specialist_1_id,
                 us_board_second_opinion_request_id: request_1_id,
                 status: :assigned
               )

      assert assigned_specialist.assigned_at

      assert SecondOpinionRequest |> Postgres.Repo.get(request_1_id) |> Map.get(:status) ==
               :assigned

      assert_enqueued(
        worker: Mailers.MailerJobs,
        args: %{
          "type" => "SPECIALIST_ASSIGNED_TO_US_BOARD_REQUEST",
          "specialist_email" => specialist_1_email
        }
      )

      Oban.drain_queue(queue: :mailers)

      # reasign to another specialist

      %{id: specialist_2_id, email: specialist_2_email} =
        Authentication.Factory.insert(:verified_specialist)

      proto =
        %{
          specialist_id: specialist_2_id,
          request_id: request_1_id
        }
        |> USBoardAssignSpecialistRequest.new()
        |> USBoardAssignSpecialistRequest.encode()

      assert conn
             |> post(admin_us_board_path(conn, :assign_specialist), proto)
             |> response(201)

      assert reassigned_specialist =
               Repo.get_by(Admin.USBoard.SecondOpinionRequest.AssignedSpecialist,
                 specialist_id: specialist_2_id,
                 us_board_second_opinion_request_id: request_1_id,
                 status: :assigned
               )

      assert reassigned_specialist.assigned_at

      assert Repo.get_by(Admin.USBoard.SecondOpinionRequest.AssignedSpecialist,
               id: assigned_specialist.id,
               specialist_id: specialist_1_id,
               us_board_second_opinion_request_id: request_1_id,
               status: :unassigned
             )

      assert SecondOpinionRequest |> Postgres.Repo.get(request_1_id) |> Map.get(:status) ==
               :assigned

      assert_enqueued(
        worker: Mailers.MailerJobs,
        args: %{
          "type" => "SPECIALIST_ASSIGNED_TO_US_BOARD_REQUEST",
          "specialist_email" => specialist_2_email
        }
      )
    end
  end

  defp insert_us_board_request(patient_id) do
    %{patient_id: patient_id, transaction_reference: "1234"}
    |> Visits.Factory.second_opinion_request_default_params()
    |> Visits.request_us_board_second_opinion()
  end
end
