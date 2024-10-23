defmodule Visits.Commands.MoveVisitFromPendingToCanceledTest do
  use Postgres.DataCase, async: true

  import Mockery.Assertions

  describe "call/2" do
    setup do
      specialist = Authentication.Factory.insert(:verified_and_approved_external)
      _basic_info = SpecialistProfile.Factory.insert(:basic_info, specialist_id: specialist.id)

      {:ok, team} = Teams.create_team(random_id(), %{})
      :ok = add_to_team(team_id: team.id, specialist_id: specialist.id)

      patient = PatientProfile.Factory.insert(:patient)
      _ = PatientProfile.Factory.insert(:basic_info, patient_id: patient.id)

      date = Date.utc_today()
      start_time1 = DateTime.utc_now() |> Timex.to_unix()

      {:ok,
       specialist: specialist, patient: patient, team: team, start_time1: start_time1, date: date}
    end

    test """
         - cancels Patient Record
         - deletes Pending Visit
         - creates Canceled Visit
         - reclaims Slot in Specialist Calendar
         """,
         %{
           specialist: specialist,
           patient: patient,
           team: team,
           start_time1: start_time1,
           date: date
         } do
      one_minute = 60
      start_time2 = start_time1 + one_minute * 2
      start_time3 = start_time1 + one_minute * 3
      start_time4 = start_time1 + one_minute * 4

      {:ok, _day_schedule} =
        Visits.DaySchedule.insert_or_update(
          %Visits.DaySchedule{specialist_id: specialist.id, date: date},
          [
            %{start_time: start_time1, visit_type: :ONLINE},
            %{start_time: start_time2, visit_type: :BOTH},
            %{start_time: start_time3, visit_type: :US_BOARD},
            %{start_time: start_time4, visit_type: :IN_OFFICE}
          ],
          []
        )

      %{id: second_opinion_request_id} =
        Visits.Factory.insert(:us_board_second_opinion_request,
          patient_id: patient.id,
          status: :requested
        )

      take_3_cmd = %Visits.Commands.TakeTimeslot{
        specialist_id: specialist.id,
        start_time: start_time3,
        patient_id: patient.id,
        chosen_medical_category_id: 1,
        visit_type: :US_BOARD,
        us_board_request_id: second_opinion_request_id
      }

      take_4_cmd = %Visits.Commands.TakeTimeslot{
        specialist_id: specialist.id,
        start_time: start_time4,
        patient_id: patient.id,
        chosen_medical_category_id: 1,
        visit_type: :IN_OFFICE
      }

      {:ok, pending_visit} = Visits.take_timeslot(take_3_cmd)
      {:ok, _pending_visit} = Visits.take_timeslot(take_4_cmd)

      {:ok, payment} =
        Visits.Payments.create(%{
          visit_id: pending_visit.record_id,
          patient_id: patient.id,
          specialist_id: specialist.id,
          team_id: team.id,
          transaction_reference: "abc123",
          payment_method: "telr"
        })

      {:ok, _canceled_visit} =
        Visits.Commands.MoveVisitFromPendingToCanceled.call(pending_visit.id, %{
          "canceled_by" => "doctor"
        })

      # creates refund because specialist canceled the visit
      assert %Visits.Visit.Payment.Refund{} =
               Repo.get_by(Visits.Visit.Payment.Refund, payment_id: payment.id)

      assert_called(PaymentsApi.Client.Refund, refund_visit: 3)

      # Cancels Patient Record
      assert %{
               active: false,
               canceled_at: record_canceled_at
             } = Repo.get_by(EMR.PatientRecords.PatientRecord, id: pending_visit.record_id)

      assert record_canceled_at

      # Deletes Pending Visit
      refute Postgres.Repo.get(Visits.PendingVisit, pending_visit.id)

      # Creates Canceled Visit
      assert %Visits.CanceledVisit{
               canceled_by: "doctor"
             } = Postgres.Repo.get(Visits.CanceledVisit, pending_visit.id)

      # Reclaims Slot in Specialist Calendar
      %Visits.DaySchedule{
        free_timeslots: [
          %Visits.FreeTimeslot{start_time: ^start_time1},
          %Visits.FreeTimeslot{start_time: ^start_time2},
          %Visits.FreeTimeslot{start_time: ^start_time3}
        ],
        taken_timeslots: [
          %Visits.TakenTimeslot{start_time: ^start_time4}
        ]
      } = Repo.one(Visits.DaySchedule)
    end

    test "doesn't call refund API when payment was done outside the application", %{
      specialist: specialist,
      patient: patient,
      team: team,
      start_time1: start_time1,
      date: date
    } do
      {:ok, _day_schedule} =
        Visits.DaySchedule.insert_or_update(
          %Visits.DaySchedule{specialist_id: specialist.id, date: date},
          [
            %{start_time: start_time1, visit_type: :ONLINE}
          ],
          []
        )

      take_timeslot_cmd = %Visits.Commands.TakeTimeslot{
        specialist_id: specialist.id,
        start_time: start_time1,
        patient_id: patient.id,
        chosen_medical_category_id: 1,
        visit_type: :ONLINE
      }

      {:ok, pending_visit} = Visits.take_timeslot(take_timeslot_cmd)

      {:ok, payment} =
        Visits.Payments.create(%{
          visit_id: pending_visit.record_id,
          patient_id: patient.id,
          specialist_id: specialist.id,
          team_id: team.id,
          transaction_reference: "abc123",
          payment_method: "external"
        })

      {:ok, _canceled_visit} =
        Visits.Commands.MoveVisitFromPendingToCanceled.call(pending_visit.id, %{
          "canceled_by" => "doctor"
        })

      # creates refund because specialist canceled the visit
      assert %Visits.Visit.Payment.Refund{} =
               Repo.get_by(Visits.Visit.Payment.Refund, payment_id: payment.id)

      refute_called(PaymentsApi.Client.Refund, refund_visit: 3)
    end
  end

  describe "triggers side effects" do
    test "when doctor canceled visit" do
      start_time = DateTime.utc_now() |> DateTime.to_unix()
      patient_id = 1
      specialist_id = 2

      {:ok, pending_visit} =
        create_pending_visit(%{
          chosen_medical_category_id: 1,
          patient_id: patient_id,
          record_id: 1,
          specialist_id: specialist_id,
          start_time: start_time,
          visit_type: :ONLINE
        })

      {:ok, _canceled_visit} =
        Visits.Commands.MoveVisitFromPendingToCanceled.call(pending_visit.id, %{
          "canceled_by" => "doctor"
        })

      assert_called(PushNotifications.Message, :send, [
        %PushNotifications.Message.VisitCanceledForPatient{
          patient_id: ^patient_id,
          specialist_title: _,
          specialist_first_name: _,
          specialist_last_name: _,
          record_id: _,
          specialist_id: ^specialist_id,
          visit_start_time: ^start_time,
          is_refunded: false
        }
      ])

      assert_called(ChannelBroadcast, :broadcast, [
        :pending_visits_update
      ])

      assert_called(ChannelBroadcast, :broadcast, [
        {:doctor_pending_visits_update, ^specialist_id}
      ])
    end

    test "when doctor canceled visit and payment was via telr refunded flag is set to true" do
      start_time = DateTime.utc_now() |> Timex.shift(days: 2) |> DateTime.to_unix()
      %{id: patient_id} = PatientProfile.Factory.insert(:patient)
      %{id: specialist_id} = Authentication.Factory.insert(:specialist)

      {:ok, pending_visit} =
        create_pending_visit(%{
          chosen_medical_category_id: 1,
          patient_id: patient_id,
          record_id: 1,
          specialist_id: specialist_id,
          start_time: start_time,
          visit_type: :ONLINE
        })

      Visits.Payments.create(%{
        visit_id: pending_visit.record_id,
        patient_id: patient_id,
        specialist_id: specialist_id,
        team_id: nil,
        transaction_reference: "abc123",
        payment_method: "telr",
        amount: "10000",
        currency: "USD"
      })

      {:ok, _canceled_visit} =
        Visits.Commands.MoveVisitFromPendingToCanceled.call(pending_visit.id, %{
          "canceled_by" => "doctor"
        })

      assert_called(PushNotifications.Message, :send, [
        %PushNotifications.Message.VisitCanceledForPatient{
          patient_id: ^patient_id,
          specialist_title: _,
          specialist_first_name: _,
          specialist_last_name: _,
          record_id: _,
          specialist_id: ^specialist_id,
          visit_start_time: ^start_time,
          is_refunded: true
        }
      ])

      assert_called(ChannelBroadcast, :broadcast, [
        :pending_visits_update
      ])

      assert_called(ChannelBroadcast, :broadcast, [
        {:doctor_pending_visits_update, ^specialist_id}
      ])
    end

    test "when doctor canceled visit and payment was external refunded flag is set to false" do
      start_time = DateTime.utc_now() |> Timex.shift(days: 2) |> DateTime.to_unix()
      %{id: patient_id} = PatientProfile.Factory.insert(:patient)
      %{id: specialist_id} = Authentication.Factory.insert(:specialist)

      {:ok, pending_visit} =
        create_pending_visit(%{
          chosen_medical_category_id: 1,
          patient_id: patient_id,
          record_id: 1,
          specialist_id: specialist_id,
          start_time: start_time,
          visit_type: :ONLINE
        })

      Visits.Payments.create(%{
        visit_id: pending_visit.record_id,
        patient_id: patient_id,
        specialist_id: specialist_id,
        team_id: nil,
        transaction_reference: "abc123",
        payment_method: "external",
        amount: "10000",
        currency: "USD"
      })

      {:ok, _canceled_visit} =
        Visits.Commands.MoveVisitFromPendingToCanceled.call(pending_visit.id, %{
          "canceled_by" => "doctor"
        })

      assert_called(PushNotifications.Message, :send, [
        %PushNotifications.Message.VisitCanceledForPatient{
          patient_id: ^patient_id,
          specialist_title: _,
          specialist_first_name: _,
          specialist_last_name: _,
          record_id: _,
          specialist_id: ^specialist_id,
          visit_start_time: ^start_time,
          is_refunded: false
        }
      ])

      assert_called(ChannelBroadcast, :broadcast, [
        :pending_visits_update
      ])

      assert_called(ChannelBroadcast, :broadcast, [
        {:doctor_pending_visits_update, ^specialist_id}
      ])
    end

    test "when patient canceled visit" do
      start_time = DateTime.utc_now() |> DateTime.to_unix()
      patient_id = 1
      specialist_id = 2

      {:ok, pending_visit} =
        create_pending_visit(%{
          chosen_medical_category_id: 1,
          patient_id: patient_id,
          record_id: 1,
          specialist_id: specialist_id,
          start_time: DateTime.utc_now() |> DateTime.to_unix(),
          visit_type: :ONLINE
        })

      {:ok, _canceled_visit} =
        Visits.Commands.MoveVisitFromPendingToCanceled.call(pending_visit.id, %{
          "canceled_by" => "patient"
        })

      assert_called(PushNotifications.Message, :send, [
        %PushNotifications.Message.VisitCanceledForSpecialist{
          patient_id: ^patient_id,
          patient_first_name: _,
          patient_last_name: _,
          record_id: _,
          specialist_id: ^specialist_id,
          visit_start_time: ^start_time
        }
      ])

      assert_called(ChannelBroadcast, :broadcast, [
        :pending_visits_update
      ])

      assert_called(ChannelBroadcast, :broadcast, [
        {:doctor_pending_visits_update, ^specialist_id}
      ])
    end
  end

  defp add_to_team(opts) do
    :ok = Teams.add_to_team(opts)
    Teams.accept_invitation(opts)
  end

  defp random_id, do: :rand.uniform(1000)

  defp create_pending_visit(params) do
    {:ok, _pending_visit} = Visits.PendingVisit.create(params)
  end
end
