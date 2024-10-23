defmodule Web.Api.Visits.VisitsControllerTest do
  use Web.ConnCase, async: true

  import Mockery.Assertions

  alias Proto.Visits.GetPaymentForVisit
  alias Proto.Visits.GetVisitsResponse

  describe "GET my_visits" do
    setup [:authenticate_patient]

    test "returns visits (for current patient and related child profiles) and associated patients data",
         %{
           conn: conn,
           current_patient: current_patient
         } do
      basic_info = PatientProfile.Factory.insert(:basic_info, patient_id: current_patient.id)

      child_patient = PatientProfile.Factory.insert(:patient)
      child_basic_info = PatientProfile.Factory.insert(:basic_info, patient_id: child_patient.id)

      cmd = %PatientProfilesManagement.Commands.RegisterFamilyRelationship{
        adult_patient_id: current_patient.id,
        child_patient_id: child_patient.id
      }

      _ = PatientProfilesManagement.FamilyRelationship.register_family_relationship(cmd)

      {:ok, visit} =
        Visits.PendingVisit.create(%{
          chosen_medical_category_id: 1,
          patient_id: current_patient.id,
          record_id: 1,
          specialist_id: 1,
          start_time: 0,
          visit_type: :ONLINE
        })

      conn = get(conn, visits_visits_path(conn, :my_visits))

      assert %GetVisitsResponse{
               visits: [%Proto.Visits.VisitDataForPatient{} = returned_visit],
               next_token: "",
               patients: [
                 %Proto.Generics.Patient{} = returned_patient1,
                 %Proto.Generics.Patient{} = returned_patient2
               ]
             } = proto_response(conn, 200, GetVisitsResponse)

      assert returned_visit.id == visit.id

      assert returned_visit.start_time == visit.start_time
      assert returned_visit.specialist_id == visit.specialist_id
      assert returned_visit.patient_id == visit.patient_id
      assert returned_visit.visit_type == visit.visit_type

      assert returned_patient1.first_name == basic_info.first_name
      assert returned_patient1.last_name == basic_info.last_name

      assert returned_patient2.first_name == child_basic_info.first_name
      assert returned_patient2.last_name == child_basic_info.last_name
    end

    test "returns visits and associated patients data when current patient is selected",
         %{
           conn: conn,
           current_patient: current_patient
         } do
      basic_info = PatientProfile.Factory.insert(:basic_info, patient_id: current_patient.id)

      child_patient = PatientProfile.Factory.insert(:patient)
      _child_basic_info = PatientProfile.Factory.insert(:basic_info, patient_id: child_patient.id)

      cmd = %PatientProfilesManagement.Commands.RegisterFamilyRelationship{
        adult_patient_id: current_patient.id,
        child_patient_id: child_patient.id
      }

      _ = PatientProfilesManagement.FamilyRelationship.register_family_relationship(cmd)

      params = %{"patient" => "0"}
      conn = get(conn, visits_visits_path(conn, :my_visits), params)

      assert %GetVisitsResponse{
               visits: [],
               next_token: "",
               patients: [
                 %Proto.Generics.Patient{} = returned_patient
               ]
             } = proto_response(conn, 200, GetVisitsResponse)

      assert returned_patient.first_name == basic_info.first_name
      assert returned_patient.last_name == basic_info.last_name
    end

    test "returns visits and associated patients data when child profile is selected",
         %{
           conn: conn,
           current_patient: current_patient
         } do
      _basic_info = PatientProfile.Factory.insert(:basic_info, patient_id: current_patient.id)

      child_patient = PatientProfile.Factory.insert(:patient)
      child_basic_info = PatientProfile.Factory.insert(:basic_info, patient_id: child_patient.id)

      cmd = %PatientProfilesManagement.Commands.RegisterFamilyRelationship{
        adult_patient_id: current_patient.id,
        child_patient_id: child_patient.id
      }

      _ = PatientProfilesManagement.FamilyRelationship.register_family_relationship(cmd)

      params = %{"patient" => to_string(child_patient.id)}
      conn = get(conn, visits_visits_path(conn, :my_visits), params)

      assert %GetVisitsResponse{
               visits: [],
               next_token: "",
               patients: [
                 %Proto.Generics.Patient{} = returned_patient
               ]
             } = proto_response(conn, 200, GetVisitsResponse)

      assert returned_patient.first_name == child_basic_info.first_name
      assert returned_patient.last_name == child_basic_info.last_name
    end

    test "returns visits with payment data and medical category name",
         %{
           conn: conn,
           current_patient: %{id: current_patient_id}
         } do
      _basic_info = PatientProfile.Factory.insert(:basic_info, patient_id: current_patient_id)
      %{id: specialist_id} = Authentication.Factory.insert(:verified_and_approved_external)

      %{id: medical_category_id} =
        SpecialistProfile.Factory.insert(:medical_category)

      SpecialistProfile.update_medical_categories([medical_category_id], specialist_id)

      {:ok, visit} =
        Visits.PendingVisit.create(%{
          chosen_medical_category_id: medical_category_id,
          patient_id: current_patient_id,
          record_id: 1,
          specialist_id: specialist_id,
          start_time: 0,
          visit_type: :ONLINE
        })

      {:ok, _payment} =
        Visits.Payments.create(%{
          visit_id: visit.record_id,
          patient_id: current_patient_id,
          specialist_id: specialist_id,
          transaction_reference: "abc123",
          payment_method: "telr",
          amount: "10000",
          currency: "AED"
        })

      conn = get(conn, visits_visits_path(conn, :my_visits))

      assert %GetVisitsResponse{
               visits: [%Proto.Visits.VisitDataForPatient{} = returned_visit],
               next_token: "",
               patients: [%Proto.Generics.Patient{}]
             } = proto_response(conn, 200, GetVisitsResponse)

      assert returned_visit.id == visit.id

      assert %Proto.Visits.PaymentsParams{
               payment_method: :TELR,
               transaction_reference: "abc123",
               amount: "10000",
               currency: "AED"
             } = returned_visit.payments_params

      assert %Proto.Visits.MedicalCategory{
               id: ^medical_category_id
             } = returned_visit.medical_category
    end

    test "returns us board visits with payment data",
         %{
           conn: conn,
           current_patient: %{id: current_patient_id}
         } do
      date = ~D[2100-11-10]
      start_time = Timex.to_unix(~N[2100-11-10T12:00:00])

      _basic_info = PatientProfile.Factory.insert(:basic_info, patient_id: current_patient_id)
      %{id: specialist_id} = Authentication.Factory.insert(:verified_and_approved_external)

      %{id: medical_category_id} =
        SpecialistProfile.Factory.insert(:medical_category, name: "U.S Board Second Opinion")

      SpecialistProfile.update_medical_categories([medical_category_id], specialist_id)

      params =
        Visits.Factory.second_opinion_request_default_params(%{
          patient_id: current_patient_id,
          status: :opinion_submitted,
          specialist_opinion: "Get better"
        })

      {:ok, %{id: request_id}} =
        Visits.request_us_board_second_opinion(params)

      {:ok, _day_schedule} =
        Visits.DaySchedule.insert_or_update(
          %Visits.DaySchedule{specialist_id: specialist_id, date: date},
          [%{start_time: start_time, visit_type: :US_BOARD}],
          []
        )

      {:ok, visit} =
        Visits.book_us_board_visit(%{
          specialist_id: specialist_id,
          timeslot_params: %{start_time: start_time, visit_type: :US_BOARD},
          patient_id: current_patient_id,
          chosen_medical_category_id: medical_category_id,
          us_board_request_id: request_id
        })

      conn = get(conn, visits_visits_path(conn, :my_visits))

      assert %GetVisitsResponse{
               visits: [%Proto.Visits.VisitDataForPatient{} = returned_visit],
               next_token: "",
               patients: [%Proto.Generics.Patient{}]
             } = proto_response(conn, 200, GetVisitsResponse)

      assert returned_visit.id == visit.id

      assert %Proto.Visits.PaymentsParams{
               payment_method: :TELR,
               amount: "499",
               currency: "USD"
             } = returned_visit.payments_params

      assert %Proto.Visits.MedicalCategory{
               id: ^medical_category_id
             } = returned_visit.medical_category
    end

    test "returns forbidden when provided id doesn't belong to any related child profile", %{
      conn: conn
    } do
      params = %{"patient" => "-1"}
      conn = get(conn, visits_visits_path(conn, :my_visits), params)

      assert response(conn, 403)
    end
  end

  describe "GET show" do
    setup [:authenticate_patient]

    setup %{current_patient: %{id: current_patient_id}} do
      _basic_info = PatientProfile.Factory.insert(:basic_info, patient_id: current_patient_id)
      %{id: specialist_id} = Authentication.Factory.insert(:verified_and_approved_external)

      %{id: medical_category_id} =
        SpecialistProfile.Factory.insert(:medical_category)

      SpecialistProfile.update_medical_categories([medical_category_id], specialist_id)

      record =
        EMR.Factory.insert(:visit_record,
          specialist_id: specialist_id,
          patient_id: current_patient_id
        )

      unix_now = DateTime.utc_now() |> DateTime.to_unix()

      {:ok, visit} =
        Visits.PendingVisit.create(%{
          chosen_medical_category_id: medical_category_id,
          patient_id: current_patient_id,
          record_id: record.id,
          specialist_id: specialist_id,
          start_time: unix_now,
          visit_type: :ONLINE
        })

      {:ok,
       visit_id: visit.id,
       medical_category_id: medical_category_id,
       specialist_id: specialist_id,
       unix_now: unix_now,
       record_id: record.id}
    end

    test "returns visit details by id", %{
      conn: conn,
      current_patient: %{id: current_patient_id},
      visit_id: visit_id,
      medical_category_id: medical_category_id,
      specialist_id: specialist_id,
      unix_now: unix_now,
      record_id: record_id
    } do
      conn = get(conn, visits_visits_path(conn, :show, visit_id))

      assert %Proto.Visits.GetPatientVisitResponse{
               visit: %Proto.Visits.VisitDataForPatient{
                 id: ^visit_id,
                 patient_id: ^current_patient_id,
                 medical_category: %Proto.Visits.MedicalCategory{id: ^medical_category_id},
                 specialist_id: ^specialist_id,
                 start_time: ^unix_now,
                 status: :ONGOING,
                 record_id: ^record_id
               }
             } = proto_response(conn, 200, Proto.Visits.GetPatientVisitResponse)
    end
  end

  describe "POST /:visit_id/move_to_canceled" do
    setup [:authenticate_patient]

    test "moves pending visit to canceled, don't refund a visit, returns Canceled visit in my_visits response",
         %{
           conn: conn,
           current_patient: patient
         } do
      doctor = Authentication.Factory.insert(:verified_and_approved_external)
      _ = PatientProfile.Factory.insert(:basic_info, patient_id: patient.id)

      {:ok, team} = Teams.create_team(random_id(), %{})
      :ok = add_to_team(team_id: team.id, specialist_id: doctor.id)

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

      {:ok, payment} =
        Visits.Payments.create(%{
          visit_id: pending_visit.record_id,
          patient_id: patient.id,
          specialist_id: doctor.id,
          team_id: team.id,
          transaction_reference: "abc123",
          payment_method: "external"
        })

      # I. Creates Canceled visit
      conn_move_to_canceled =
        post(conn, visits_visits_path(conn, :move_to_canceled, pending_visit.id))

      assert %Proto.Visits.MoveVisitToCanceledResponse{refund: false} =
               proto_response(
                 conn_move_to_canceled,
                 200,
                 Proto.Visits.MoveVisitToCanceledResponse
               )

      refute Postgres.Repo.get(Visits.PendingVisit, pending_visit.id)
      canceled_visit = Postgres.Repo.get(Visits.CanceledVisit, pending_visit.id)

      assert canceled_visit
      assert canceled_visit.canceled_by == "patient"

      # II Doesn't send a refund because visit was scheduled for today and was canceled by patient
      assert is_nil(Postgres.Repo.get_by(Visits.Visit.Payment.Refund, payment_id: payment.id))
      refute_called(PaymentsApi.Client.Refund, refund_visit: 3)

      # III. Returnes Canceled visit as part of /my_visits response
      conn_my_visits = get(conn, visits_visits_path(conn, :my_visits))

      canceled_status_proto_index = Proto.Visits.VisitDataForPatient.Status.key(4)

      assert %GetVisitsResponse{
               visits: [
                 %Proto.Visits.VisitDataForPatient{
                   status: ^canceled_status_proto_index
                 }
               ]
             } = proto_response(conn_my_visits, 200, GetVisitsResponse)
    end

    test "creates a refund for a patient cancellation is 24h before visit", %{
      conn: conn,
      current_patient: patient
    } do
      doctor = Authentication.Factory.insert(:verified_and_approved_external)
      _ = PatientProfile.Factory.insert(:basic_info, patient_id: patient.id)

      {:ok, team} = Teams.create_team(random_id(), %{})
      :ok = add_to_team(team_id: team.id, specialist_id: doctor.id)

      date = Timex.shift(DateTime.utc_now(), hours: 25)
      start_time = Timex.to_unix(date)

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

      # I. Creates Canceled visit
      conn_move_to_canceled =
        post(conn, visits_visits_path(conn, :move_to_canceled, pending_visit.id))

      assert %Proto.Visits.MoveVisitToCanceledResponse{refund: true} =
               proto_response(
                 conn_move_to_canceled,
                 200,
                 Proto.Visits.MoveVisitToCanceledResponse
               )

      refute Postgres.Repo.get(Visits.PendingVisit, pending_visit.id)
      canceled_visit = Postgres.Repo.get(Visits.CanceledVisit, pending_visit.id)

      assert canceled_visit
      assert canceled_visit.canceled_by == "patient"

      # II Sends a refund because visit was scheduled in 25h and was canceled by patient
      assert %Visits.Visit.Payment.Refund{} =
               Postgres.Repo.get_by(Visits.Visit.Payment.Refund, payment_id: payment.id)

      assert_called(PaymentsApi.Client.Refund, refund_visit: 3)
    end
  end

  describe "GET payment_for_visit" do
    setup [:authenticate_patient]

    test "returns payment for regular visit", %{conn: conn, current_patient: patient} do
      specialist = Authentication.Factory.insert(:verified_and_approved_external)

      {:ok, team} = Teams.create_team(random_id(), %{})
      :ok = add_to_team(team_id: team.id, specialist_id: specialist.id)

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
          team_id: team.id,
          amount: "1000",
          currency: "AED",
          transaction_reference: "abc123",
          payment_method: "external"
        })

      conn = get(conn, ~p"/api/visits/payment/#{record_id}")

      assert %GetPaymentForVisit{
               amount: "1000",
               currency: "AED",
               record_id: ^record_id,
               payment_method: "in office"
             } = proto_response(conn, 200, GetPaymentForVisit)
    end
  end

  defp random_id, do: :rand.uniform(1000)

  defp add_to_team(opts) do
    :ok = Teams.add_to_team(opts)
    Teams.accept_invitation(opts)
  end
end
