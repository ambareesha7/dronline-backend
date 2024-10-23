defmodule Web.PanelApi.UsBoardSecondOpinionControllerTest do
  use Oban.Testing, repo: Postgres.Repo
  use Web.ConnCase

  import Mockery.Assertions

  alias Postgres.Repo
  alias Proto.Visits.PostUSBoardSpecialistOpinion
  alias Visits.USBoard.SecondOpinionAssignedSpecialist
  alias Visits.USBoard.SecondOpinionRequest

  describe "index" do
    setup [:proto_content, :authenticate_external]

    test "returns a list of requests for current specialist", %{
      conn: conn,
      current_external: specialist
    } do
      patient = PatientProfile.Factory.insert(:patient)

      _basic_info =
        PatientProfile.Factory.insert(:basic_info,
          patient_id: patient.id,
          first_name: "Krypto",
          last_name: "Dog",
          birth_date: ~D[1992-11-30],
          gender: "MALE"
        )

      %{id: second_opinion_request_id} =
        Visits.Factory.insert(:us_board_second_opinion_request,
          patient_id: patient.id,
          patient_email: "krypto@doghouse.woof",
          status: :in_progress
        )

      _assigned_specialist =
        Visits.Factory.insert(:second_opinion_assigned_specialist,
          us_board_second_opinion_request_id: second_opinion_request_id,
          specialist_id: specialist.id
        )

      conn = get(conn, ~p"/panel_api/us_board_2nd_opinion")

      assert %Proto.Visits.GetSpecialistsUSBoardOpinions{
               requested_opinions: [
                 %Proto.Visits.SpecialistsUSBoardOpinion{
                   patient: %Proto.Visits.USBoardPatient{
                     first_name: "Krypto",
                     last_name: "Dog",
                     email: "krypto@doghouse.woof",
                     gender: :MALE,
                     birth_date: %Proto.Generics.DateTime{timestamp: _}
                   },
                   id: ^second_opinion_request_id,
                   status: :IN_PROGRESS,
                   assigned_at: assigned_at,
                   accepted_at: accepted_at
                 }
               ]
             } = proto_response(conn, 200, Proto.Visits.GetSpecialistsUSBoardOpinions)

      assert assigned_at
      assert accepted_at
    end

    test "returns a list of requests without patient for current specialist", %{
      conn: conn,
      current_external: specialist
    } do
      {:ok, %{id: second_opinion_request_id}} =
        Visits.request_second_opinion_from_landing(%{
          patient_email: "krypto@doghouse.woof",
          status: :landing_form
        })

      _assigned_specialist =
        Visits.Factory.insert(:second_opinion_assigned_specialist,
          us_board_second_opinion_request_id: second_opinion_request_id,
          specialist_id: specialist.id
        )

      conn = get(conn, ~p"/panel_api/us_board_2nd_opinion")

      assert %Proto.Visits.GetSpecialistsUSBoardOpinions{
               requested_opinions: [
                 %Proto.Visits.SpecialistsUSBoardOpinion{
                   patient: %Proto.Visits.USBoardPatient{
                     first_name: "",
                     last_name: "",
                     email: "krypto@doghouse.woof"
                   },
                   id: ^second_opinion_request_id,
                   status: :LANDING_FORM,
                   assigned_at: assigned_at,
                   accepted_at: accepted_at
                 }
               ]
             } = proto_response(conn, 200, Proto.Visits.GetSpecialistsUSBoardOpinions)

      assert accepted_at
      assert assigned_at
    end

    test "shows rejected requests", %{
      conn: conn,
      current_external: specialist
    } do
      patient = PatientProfile.Factory.insert(:patient)

      _basic_info =
        PatientProfile.Factory.insert(:basic_info,
          patient_id: patient.id,
          first_name: "Krypto",
          last_name: "Dog"
        )

      %{id: second_opinion_request_id} =
        Visits.Factory.insert(:us_board_second_opinion_request,
          patient_id: patient.id,
          patient_email: "krypto@doghouse.woof",
          status: :requested
        )

      _assigned_specialist =
        Visits.Factory.insert(:second_opinion_assigned_specialist,
          us_board_second_opinion_request_id: second_opinion_request_id,
          specialist_id: specialist.id,
          status: :assigned
        )

      {:ok, _request} =
        SecondOpinionAssignedSpecialist.reject_request(specialist.id, second_opinion_request_id)

      conn = get(conn, ~p"/panel_api/us_board_2nd_opinion")

      assert %Proto.Visits.GetSpecialistsUSBoardOpinions{
               requested_opinions: [
                 %Proto.Visits.SpecialistsUSBoardOpinion{
                   patient: _,
                   id: ^second_opinion_request_id,
                   status: :REJECTED,
                   assigned_at: assigned_at,
                   accepted_at: nil,
                   rejected_at: rejected_at
                 }
               ]
             } = proto_response(conn, 200, Proto.Visits.GetSpecialistsUSBoardOpinions)

      assert rejected_at
      assert assigned_at
    end

    test "doesn't return requests of other specialists", %{conn: conn} do
      patient = PatientProfile.Factory.insert(:patient)
      specialist_id = :rand.uniform(1000)
      _basic_info = PatientProfile.Factory.insert(:basic_info, patient_id: patient.id)

      second_opinion_request =
        Visits.Factory.insert(:us_board_second_opinion_request, patient_id: patient.id)

      _assigned_specialist =
        Visits.Factory.insert(:second_opinion_assigned_specialist,
          us_board_second_opinion_request_id: second_opinion_request.id,
          specialist_id: specialist_id
        )

      conn = get(conn, ~p"/panel_api/us_board_2nd_opinion")

      assert %Proto.Visits.GetSpecialistsUSBoardOpinions{
               requested_opinions: []
             } = proto_response(conn, 200, Proto.Visits.GetSpecialistsUSBoardOpinions)
    end

    test "doesn't return unassigned requests for specialists", %{
      conn: conn,
      current_external: specialist
    } do
      patient = PatientProfile.Factory.insert(:patient)
      _basic_info = PatientProfile.Factory.insert(:basic_info, patient_id: patient.id)

      second_opinion_request =
        Visits.Factory.insert(:us_board_second_opinion_request, patient_id: patient.id)

      _assigned_specialist =
        Visits.Factory.insert(:second_opinion_assigned_specialist,
          us_board_second_opinion_request_id: second_opinion_request.id,
          specialist_id: specialist.id,
          status: :unassigned
        )

      conn = get(conn, ~p"/panel_api/us_board_2nd_opinion")

      assert %Proto.Visits.GetSpecialistsUSBoardOpinions{
               requested_opinions: []
             } = proto_response(conn, 200, Proto.Visits.GetSpecialistsUSBoardOpinions)
    end
  end

  describe "show" do
    setup [:proto_content, :authenticate_external]

    test "returns the details about the selected request", %{
      conn: conn
    } do
      patient = PatientProfile.Factory.insert(:patient)
      specialist_id = :rand.uniform(1000)

      patient_description = "I'm sick"
      specialist_opinion = "yes"

      _basic_info = PatientProfile.Factory.insert(:basic_info, patient_id: patient.id)

      second_opinion_request =
        Visits.Factory.insert(:us_board_second_opinion_request,
          patient_id: patient.id,
          patient_description: patient_description,
          specialist_opinion: specialist_opinion
        )

      _assigned_specialist =
        Visits.Factory.insert(:second_opinion_assigned_specialist,
          us_board_second_opinion_request_id: second_opinion_request.id,
          specialist_id: specialist_id
        )

      conn = get(conn, ~p"/panel_api/us_board_2nd_opinion/#{second_opinion_request.id}")

      assert %Proto.Visits.USBoardRequestDetails{
               files: [%Proto.Visits.USBoardFilesToDownload{download_url: download_url}],
               patient_description: ^patient_description,
               specialist_opinion: ^specialist_opinion,
               inserted_at: inserted_at
             } =
               proto_response(conn, 200, Proto.Visits.USBoardRequestDetails)

      assert download_url =~ "https://storage.googleapis.com/file.pdf"
      assert inserted_at
    end
  end

  describe "by_visit_id" do
    setup [:proto_content, :authenticate_external]

    test "returns the details about the selected request", %{
      conn: conn
    } do
      patient = PatientProfile.Factory.insert(:patient)
      specialist_id = :rand.uniform(1000)

      patient_description = "I'm sick"
      specialist_opinion = "yes"

      _basic_info = PatientProfile.Factory.insert(:basic_info, patient_id: patient.id)

      us_board_medical_category =
        SpecialistProfile.Factory.insert(:medical_category, name: "U.S Board Second Opinion")

      %{id: second_opinion_request_id} =
        Visits.Factory.insert(:us_board_second_opinion_request,
          patient_id: patient.id,
          patient_description: patient_description,
          specialist_opinion: specialist_opinion,
          status: :opinion_submitted
        )

      _assigned_specialist =
        Visits.Factory.insert(:second_opinion_assigned_specialist,
          us_board_second_opinion_request_id: second_opinion_request_id,
          specialist_id: specialist_id
        )

      date = Date.utc_today()
      start_time = Timex.to_unix(date)

      {:ok, _day_schedule} =
        Visits.DaySchedule.insert_or_update(
          %Visits.DaySchedule{specialist_id: specialist_id, date: date},
          [%{start_time: start_time, visit_type: :US_BOARD}],
          []
        )

      cmd = %Visits.Commands.TakeTimeslot{
        specialist_id: specialist_id,
        start_time: start_time,
        patient_id: patient.id,
        chosen_medical_category_id: us_board_medical_category.id,
        us_board_request_id: second_opinion_request_id,
        visit_type: :US_BOARD
      }

      {:ok, visit} = Visits.take_timeslot(cmd)

      {:ok, _request} =
        Visits.USBoard.move_request_to_call_scheduled(second_opinion_request_id, visit.id)

      conn = get(conn, ~p"/panel_api/us_board_2nd_opinion/by_visit_id/#{visit.id}")

      assert %Proto.Visits.USBoardRequestDetails{
               files: [%Proto.Visits.USBoardFilesToDownload{download_url: download_url}],
               patient_description: ^patient_description,
               specialist_opinion: ^specialist_opinion,
               id: ^second_opinion_request_id,
               status: :CALL_SCHEDULED
             } = proto_response(conn, 200, Proto.Visits.USBoardRequestDetails)

      assert download_url =~ "https://storage.googleapis.com/file.pdf"
    end
  end

  describe "udpate" do
    setup [:proto_content, :authenticate_external]

    test "updates specialist opinion without sending it to patient", %{conn: conn} do
      patient = PatientProfile.Factory.insert(:patient)
      specialist_id = :rand.uniform(1000)

      patient_description = "I'm sick"

      second_opinion_request =
        Visits.Factory.insert(:us_board_second_opinion_request,
          patient_id: patient.id,
          patient_description: patient_description,
          status: :in_progress
        )

      _assigned_specialist =
        Visits.Factory.insert(:second_opinion_assigned_specialist,
          us_board_second_opinion_request_id: second_opinion_request.id,
          specialist_id: specialist_id
        )

      proto =
        %PostUSBoardSpecialistOpinion{specialist_opinion: "yes"}
        |> PostUSBoardSpecialistOpinion.encode()

      conn = put(conn, ~p"/panel_api/us_board_2nd_opinion/#{second_opinion_request.id}", proto)

      assert %Proto.Visits.USBoardRequestDetails{
               patient_description: ^patient_description,
               specialist_opinion: "yes"
             } = proto_response(conn, 200, Proto.Visits.USBoardRequestDetails)

      assert %{status: :in_progress} =
               Repo.get(SecondOpinionRequest, second_opinion_request.id)

      refute_enqueued(
        worker: Mailers.MailerJobs,
        args: %{
          "type" => "SPECIALIST_SUBMITTED_SECOND_OPINION",
          "patient_email" => second_opinion_request.patient_email,
          "us_board_request_id" => second_opinion_request.id
        }
      )
    end
  end

  describe "submit_opinion" do
    setup [:proto_content, :authenticate_external]

    test "updates specialist opinion and changes status to opinion_assigned", %{conn: conn} do
      %{id: patient_id} = PatientProfile.Factory.insert(:patient)
      %{id: specialist_id} = Authentication.Factory.insert(:specialist)

      basic_info = SpecialistProfile.Factory.insert(:basic_info, specialist_id: specialist_id)

      patient_description = "I'm sick"

      %{id: second_opinion_request_id, patient_email: patient_email} =
        Visits.Factory.insert(:us_board_second_opinion_request,
          patient_id: patient_id,
          patient_description: patient_description,
          status: :in_progress
        )

      _assigned_specialist =
        Visits.Factory.insert(:second_opinion_assigned_specialist,
          us_board_second_opinion_request_id: second_opinion_request_id,
          specialist_id: specialist_id
        )

      proto =
        %PostUSBoardSpecialistOpinion{specialist_opinion: "yes"}
        |> PostUSBoardSpecialistOpinion.encode()

      conn =
        put(
          conn,
          ~p"/panel_api/us_board_2nd_opinion/#{second_opinion_request_id}/submit_opinion",
          proto
        )

      assert %Proto.Visits.USBoardRequestDetails{
               patient_description: ^patient_description,
               specialist_opinion: "yes"
             } = proto_response(conn, 200, Proto.Visits.USBoardRequestDetails)

      assert %{status: :opinion_submitted} =
               Repo.get(SecondOpinionRequest, second_opinion_request_id)

      assert_called(PushNotifications.Message, :send, [
        %PushNotifications.Message.USBoardOpinionSubmitted{
          send_to_patient_id: ^patient_id,
          us_board_request_id: ^second_opinion_request_id
        }
      ])

      assert_enqueued(
        worker: Mailers.MailerJobs,
        args: %{
          "type" => "SPECIALIST_SUBMITTED_SECOND_OPINION",
          "patient_email" => patient_email,
          "us_board_request_id" => second_opinion_request_id,
          "specialist_name" => "#{basic_info.first_name} #{basic_info.last_name}"
        }
      )
    end
  end

  describe "accept/reject" do
    setup [:authenticate_external]

    test "Accepts us board 2nd opinion", %{conn: conn, current_external: specialist} do
      %{id: patient_id} = PatientProfile.Factory.insert(:patient)
      basic_info = SpecialistProfile.Factory.insert(:basic_info, specialist_id: specialist.id)

      %{id: second_opinion_request_id} =
        Visits.Factory.insert(:us_board_second_opinion_request,
          patient_id: patient_id,
          status: :assigned
        )

      assigned_specialist =
        Visits.Factory.insert(:second_opinion_assigned_specialist,
          us_board_second_opinion_request_id: second_opinion_request_id,
          specialist_id: specialist.id,
          status: "assigned",
          accepted_at: nil,
          rejected_at: nil
        )

      next_second_opinion_request =
        Visits.Factory.insert(:us_board_second_opinion_request,
          patient_id: patient_id
        )

      assigned_specialist_to_next_request =
        Visits.Factory.insert(:second_opinion_assigned_specialist,
          us_board_second_opinion_request_id: next_second_opinion_request.id,
          specialist_id: specialist.id,
          status: "assigned",
          accepted_at: nil,
          rejected_at: nil
        )

      conn = post(conn, ~p"/panel_api/us_board_2nd_opinion/#{second_opinion_request_id}/accept")

      assert conn.status == 200

      assert %{status: :accepted, accepted_at: accepted_at, rejected_at: nil} =
               Repo.get(SecondOpinionAssignedSpecialist, assigned_specialist.id)

      assert accepted_at

      assert %{status: :assigned} =
               Repo.get(SecondOpinionAssignedSpecialist, assigned_specialist_to_next_request.id)

      assert %{status: :in_progress} = Repo.get(SecondOpinionRequest, second_opinion_request_id)

      assert_called(PushNotifications.Message, :send, [
        %PushNotifications.Message.USBoardRequestAccepted{
          send_to_patient_id: ^patient_id,
          us_board_request_id: ^second_opinion_request_id
        }
      ])

      assert_enqueued(
        worker: Mailers.MailerJobs,
        args: %{
          "type" => "SPECIALIST_ACCEPTED_US_BOARD_REQUEST",
          "specialist_name" => "#{basic_info.first_name} #{basic_info.last_name}"
        }
      )
    end

    test "Rejects us board 2nd opinion", %{conn: conn, current_external: specialist} do
      patient = PatientProfile.Factory.insert(:patient)
      _patient_basic_info = PatientProfile.Factory.insert(:basic_info, patient_id: patient.id)

      second_opinion_request =
        Visits.Factory.insert(:us_board_second_opinion_request,
          patient_id: patient.id,
          status: :assigned
        )

      assigned_specialist =
        Visits.Factory.insert(:second_opinion_assigned_specialist,
          us_board_second_opinion_request_id: second_opinion_request.id,
          specialist_id: specialist.id,
          status: :assigned,
          accepted_at: nil,
          rejected_at: nil
        )

      next_second_opinion_request =
        Visits.Factory.insert(:us_board_second_opinion_request,
          patient_id: patient.id,
          status: :assigned
        )

      assigned_specialist_to_next_request =
        Visits.Factory.insert(:second_opinion_assigned_specialist,
          us_board_second_opinion_request_id: next_second_opinion_request.id,
          specialist_id: specialist.id,
          status: :assigned,
          accepted_at: nil,
          rejected_at: nil
        )

      conn = post(conn, ~p"/panel_api/us_board_2nd_opinion/#{second_opinion_request.id}/reject")

      assert conn.status == 200

      assert %{status: :rejected, accepted_at: nil, rejected_at: rejected_at} =
               Repo.get(SecondOpinionAssignedSpecialist, assigned_specialist.id)

      assert rejected_at

      assert %{status: :assigned} =
               Repo.get(SecondOpinionAssignedSpecialist, assigned_specialist_to_next_request.id)

      assert_enqueued(
        worker: Mailers.MailerJobs,
        args: %{"type" => "SPECIALIST_REJECTED_US_BOARD_REQUEST"}
      )

      assert %{status: :rejected} = Repo.get(SecondOpinionRequest, second_opinion_request.id)
      assert %{status: :assigned} = Repo.get(SecondOpinionRequest, next_second_opinion_request.id)
    end

    test "Shows requests twice when reassigning the same specialist after rejecting us board 2nd opinion",
         %{conn: conn, current_external: specialist} do
      patient = PatientProfile.Factory.insert(:patient)
      _patient_basic_info = PatientProfile.Factory.insert(:basic_info, patient_id: patient.id)

      %{id: second_opinion_request_id} =
        Visits.Factory.insert(:us_board_second_opinion_request,
          patient_id: patient.id,
          status: :assigned
        )

      assigned_specialist =
        Visits.Factory.insert(:second_opinion_assigned_specialist,
          us_board_second_opinion_request_id: second_opinion_request_id,
          specialist_id: specialist.id,
          status: :assigned,
          accepted_at: nil,
          rejected_at: nil
        )

      conn
      |> post(~p"/panel_api/us_board_2nd_opinion/#{second_opinion_request_id}/reject")
      |> response(200)

      assert %{status: :rejected, accepted_at: nil, rejected_at: rejected_at} =
               Repo.get(SecondOpinionAssignedSpecialist, assigned_specialist.id)

      assert rejected_at
      assert %{status: :rejected} = Repo.get(SecondOpinionRequest, second_opinion_request_id)

      # reassign
      Visits.assign_specialist_to_second_opinion_request(specialist.id, second_opinion_request_id)

      # fetch again, should return both requests
      conn = get(conn, ~p"/panel_api/us_board_2nd_opinion")

      assert %Proto.Visits.GetSpecialistsUSBoardOpinions{
               requested_opinions: [
                 %Proto.Visits.SpecialistsUSBoardOpinion{
                   id: ^second_opinion_request_id,
                   status: :ASSIGNED,
                   accepted_at: nil,
                   rejected_at: nil
                 },
                 %Proto.Visits.SpecialistsUSBoardOpinion{
                   id: ^second_opinion_request_id,
                   status: :REJECTED,
                   accepted_at: nil,
                   rejected_at: rejected_at
                 }
               ]
             } = proto_response(conn, 200, Proto.Visits.GetSpecialistsUSBoardOpinions)

      assert rejected_at
    end
  end
end
