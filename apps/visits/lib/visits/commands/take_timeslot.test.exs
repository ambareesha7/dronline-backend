defmodule Visits.Commands.TakeTimeslotTest do
  use Postgres.DataCase, async: false
  use Oban.Testing, repo: Postgres.Repo

  import Mockery.Assertions

  alias EMR.PatientRecords.PatientRecord
  alias Postgres.Repo
  alias Visits.Commands.TakeTimeslot
  alias Visits.DaySchedule

  @minutes_in_timeslot 30
  @seconds_in_minute 60
  @seconds_in_timeslot @minutes_in_timeslot * @seconds_in_minute

  defp start_times(start_time, count) when is_integer(start_time) do
    for i <- 0..(count - 1) do
      start_time + i * @seconds_in_timeslot
    end
  end

  defp start_times(start_time, count) do
    start_time
    |> Timex.to_unix()
    |> start_times(count)
  end

  test "doesn't allow to take timeslot in the past" do
    date = ~D[1992-11-30]
    [start_time] = start_times(date, 1)

    cmd = %TakeTimeslot{
      chosen_medical_category_id: 1,
      patient_id: 1,
      specialist_id: 1,
      start_time: start_time,
      visit_type: :ONLINE
    }

    assert {:error, error_msg} = TakeTimeslot.call(cmd)
    assert error_msg == TakeTimeslot.no_longer_available()
  end

  test "doesn't allow to take unexisting timeslot" do
    date = ~D[2100-11-30]
    [start_time] = start_times(date, 1)

    cmd = %TakeTimeslot{
      chosen_medical_category_id: 1,
      patient_id: 1,
      specialist_id: 1,
      start_time: start_time,
      visit_type: :ONLINE
    }

    assert {:error, error_msg} = TakeTimeslot.call(cmd)
    assert error_msg == TakeTimeslot.no_longer_available()
  end

  test "doesn't allow to take already taken timeslot" do
    date = ~D[2100-11-30]
    [start_time] = start_times(date, 1)

    {:ok, _existing_schedule} =
      DaySchedule.insert_or_update(
        %DaySchedule{specialist_id: 1, date: date},
        [],
        [
          %{
            start_time: start_time,
            patient_id: 1,
            record_id: 1,
            visit_id: UUID.uuid4(),
            id: UUID.uuid4(),
            visit_type: :ONLINE
          }
        ]
      )

    cmd = %TakeTimeslot{
      chosen_medical_category_id: 1,
      patient_id: 1,
      specialist_id: 1,
      start_time: start_time,
      visit_type: :ONLINE
    }

    assert {:error, error_msg} = TakeTimeslot.call(cmd)
    assert error_msg == TakeTimeslot.no_longer_available()
  end

  test "doesn't allow to take timeslot of different visit_type" do
    date = ~D[2100-11-30]
    [start_time] = start_times(date, 1)

    specialist_id = 1
    %{id: patient_id} = PatientProfile.Factory.insert(:patient)

    _basic_info =
      PatientProfile.Factory.insert(:basic_info, patient_id: patient_id)

    {:ok, _existing_schedule} =
      DaySchedule.insert_or_update(
        %DaySchedule{specialist_id: specialist_id, date: date},
        [%{start_time: start_time, visit_type: :ONLINE}],
        []
      )

    cmd = %TakeTimeslot{
      chosen_medical_category_id: 1,
      patient_id: patient_id,
      specialist_id: specialist_id,
      start_time: start_time,
      visit_type: :IN_OFFICE
    }

    assert {:error, error_msg} = TakeTimeslot.call(cmd)
    assert error_msg == TakeTimeslot.incorrect_visit_type()
  end

  test "allows to take timeslot for :IN_OFFICE visit for timeslot with visit_type: :BOTH" do
    date = ~D[2100-11-30]
    [start_time] = start_times(date, 1)

    specialist_id = 1
    %{id: patient_id} = PatientProfile.Factory.insert(:patient)

    _basic_info =
      PatientProfile.Factory.insert(:basic_info, patient_id: patient_id)

    {:ok, _existing_schedule} =
      DaySchedule.insert_or_update(
        %DaySchedule{specialist_id: specialist_id, date: date},
        [%{start_time: start_time, visit_type: :BOTH}],
        []
      )

    cmd = %TakeTimeslot{
      chosen_medical_category_id: 1,
      patient_id: patient_id,
      specialist_id: specialist_id,
      start_time: start_time,
      visit_type: :IN_OFFICE
    }

    assert {:ok, %Visits.PendingVisit{}} = TakeTimeslot.call(cmd)

    assert Repo.get_by(PatientRecord, %{
             type: "IN_OFFICE",
             with_specialist_id: specialist_id,
             patient_id: patient_id
           })
  end

  test "allows to take timeslot for :ONLINE visit for timeslot with visit_type: :BOTH" do
    date = ~D[2100-11-30]
    [start_time] = start_times(date, 1)

    specialist_id = 1
    %{id: patient_id} = PatientProfile.Factory.insert(:patient)

    _basic_info =
      PatientProfile.Factory.insert(:basic_info, patient_id: patient_id)

    {:ok, _existing_schedule} =
      DaySchedule.insert_or_update(
        %DaySchedule{specialist_id: specialist_id, date: date},
        [%{start_time: start_time, visit_type: :BOTH}],
        []
      )

    cmd = %TakeTimeslot{
      chosen_medical_category_id: 1,
      patient_id: patient_id,
      specialist_id: specialist_id,
      start_time: start_time,
      visit_type: :ONLINE
    }

    assert {:ok, %Visits.PendingVisit{}} = TakeTimeslot.call(cmd)

    assert Repo.get_by(PatientRecord, %{
             type: "VISIT",
             with_specialist_id: specialist_id,
             patient_id: patient_id
           })
  end

  test "does not allow to schedule two US_BOARD visits for same second_opinion_request_id with visit_type: :BOTH" do
    date = ~D[2100-11-30]
    [start_time_1, start_time_2] = start_times(date, 2)

    specialist_id = 1
    %{id: patient_id} = PatientProfile.Factory.insert(:patient)

    _basic_info =
      PatientProfile.Factory.insert(:basic_info, patient_id: patient_id)

    %{id: second_opinion_request_id} =
      Visits.Factory.insert(:us_board_second_opinion_request,
        patient_id: patient_id,
        patient_email: "krypto@doghouse.woof",
        status: :requested
      )

    {:ok, _existing_schedule} =
      DaySchedule.insert_or_update(
        %DaySchedule{specialist_id: specialist_id, date: date},
        [
          %{start_time: start_time_1, visit_type: :BOTH},
          %{start_time: start_time_2, visit_type: :BOTH}
        ],
        []
      )

    cmd = %TakeTimeslot{
      chosen_medical_category_id: 1,
      patient_id: patient_id,
      specialist_id: specialist_id,
      start_time: start_time_1,
      visit_type: :US_BOARD,
      us_board_request_id: second_opinion_request_id
    }

    assert {:ok, %Visits.PendingVisit{}} = TakeTimeslot.call(cmd)

    assert Repo.get_by(PatientRecord, %{
             type: "US_BOARD",
             with_specialist_id: specialist_id,
             patient_id: patient_id
           })

    cmd = %TakeTimeslot{
      chosen_medical_category_id: 1,
      patient_id: patient_id,
      specialist_id: specialist_id,
      start_time: start_time_2,
      visit_type: :US_BOARD,
      us_board_request_id: second_opinion_request_id
    }

    assert {:error, "cannot schedule two visits for same second opinion"} = TakeTimeslot.call(cmd)
  end

  test "does not allow to schedule two US_BOARD visits for same second_opinion_request_id with visit_type: :ONLINE" do
    date = ~D[2100-11-30]
    [start_time_1, start_time_2] = start_times(date, 2)

    specialist_id = 1
    %{id: patient_id} = PatientProfile.Factory.insert(:patient)

    _basic_info =
      PatientProfile.Factory.insert(:basic_info, patient_id: patient_id)

    %{id: second_opinion_request_id} =
      Visits.Factory.insert(:us_board_second_opinion_request,
        patient_id: patient_id,
        patient_email: "krypto@doghouse.woof",
        status: :requested
      )

    {:ok, _existing_schedule} =
      DaySchedule.insert_or_update(
        %DaySchedule{specialist_id: specialist_id, date: date},
        [
          %{start_time: start_time_1, visit_type: :ONLINE},
          %{start_time: start_time_2, visit_type: :ONLINE}
        ],
        []
      )

    cmd = %TakeTimeslot{
      chosen_medical_category_id: 1,
      patient_id: patient_id,
      specialist_id: specialist_id,
      start_time: start_time_1,
      visit_type: :US_BOARD,
      us_board_request_id: second_opinion_request_id
    }

    assert {:ok, %Visits.PendingVisit{}} = TakeTimeslot.call(cmd)

    assert Repo.get_by(PatientRecord, %{
             type: "US_BOARD",
             with_specialist_id: specialist_id,
             patient_id: patient_id
           })

    cmd = %TakeTimeslot{
      chosen_medical_category_id: 1,
      patient_id: patient_id,
      specialist_id: specialist_id,
      start_time: start_time_2,
      visit_type: :US_BOARD,
      us_board_request_id: second_opinion_request_id
    }

    assert {:error, "cannot schedule two visits for same second opinion"} = TakeTimeslot.call(cmd)
  end

  test "does not allow to schedule two US_BOARD visits for same second_opinion_request_id with visit_type: :IN_OFFICE" do
    date = ~D[2100-11-30]
    [start_time_1, start_time_2] = start_times(date, 2)

    specialist_id = 1
    %{id: patient_id} = PatientProfile.Factory.insert(:patient)

    _basic_info =
      PatientProfile.Factory.insert(:basic_info, patient_id: patient_id)

    %{id: second_opinion_request_id} =
      Visits.Factory.insert(:us_board_second_opinion_request,
        patient_id: patient_id,
        patient_email: "krypto@doghouse.woof",
        status: :requested
      )

    {:ok, _existing_schedule} =
      DaySchedule.insert_or_update(
        %DaySchedule{specialist_id: specialist_id, date: date},
        [
          %{start_time: start_time_1, visit_type: :IN_OFFICE},
          %{start_time: start_time_2, visit_type: :IN_OFFICE}
        ],
        []
      )

    cmd = %TakeTimeslot{
      chosen_medical_category_id: 1,
      patient_id: patient_id,
      specialist_id: specialist_id,
      start_time: start_time_1,
      visit_type: :US_BOARD,
      us_board_request_id: second_opinion_request_id
    }

    assert {:ok, %Visits.PendingVisit{}} = TakeTimeslot.call(cmd)

    assert Repo.get_by(PatientRecord, %{
             type: "US_BOARD",
             with_specialist_id: specialist_id,
             patient_id: patient_id
           })

    cmd = %TakeTimeslot{
      chosen_medical_category_id: 1,
      patient_id: patient_id,
      specialist_id: specialist_id,
      start_time: start_time_2,
      visit_type: :US_BOARD,
      us_board_request_id: second_opinion_request_id
    }

    assert {:error, "cannot schedule two visits for same second opinion"} = TakeTimeslot.call(cmd)
  end

  test "does not allow to schedule two US_BOARD visits for same second_opinion_request_id with visit_type: :US_BOARD" do
    date = ~D[2100-11-30]
    [start_time_1, start_time_2] = start_times(date, 2)

    specialist_id = 1
    %{id: patient_id} = PatientProfile.Factory.insert(:patient)

    _basic_info =
      PatientProfile.Factory.insert(:basic_info, patient_id: patient_id)

    %{id: second_opinion_request_id} =
      Visits.Factory.insert(:us_board_second_opinion_request,
        patient_id: patient_id,
        patient_email: "krypto@doghouse.woof",
        status: :requested
      )

    {:ok, _existing_schedule} =
      DaySchedule.insert_or_update(
        %DaySchedule{specialist_id: specialist_id, date: date},
        [
          %{start_time: start_time_1, visit_type: :US_BOARD},
          %{start_time: start_time_2, visit_type: :US_BOARD}
        ],
        []
      )

    cmd = %TakeTimeslot{
      chosen_medical_category_id: 1,
      patient_id: patient_id,
      specialist_id: specialist_id,
      start_time: start_time_1,
      visit_type: :US_BOARD,
      us_board_request_id: second_opinion_request_id
    }

    assert {:ok, %Visits.PendingVisit{}} = TakeTimeslot.call(cmd)

    assert Repo.get_by(PatientRecord, %{
             type: "US_BOARD",
             with_specialist_id: specialist_id,
             patient_id: patient_id
           })

    cmd = %TakeTimeslot{
      chosen_medical_category_id: 1,
      patient_id: patient_id,
      specialist_id: specialist_id,
      start_time: start_time_2,
      visit_type: :US_BOARD,
      us_board_request_id: second_opinion_request_id
    }

    assert {:error, "cannot schedule two visits for same second opinion"} = TakeTimeslot.call(cmd)
  end

  test "allows to take a :US_BOARD visit type timeslot with visit_type: :BOTH" do
    date = ~D[2100-11-30]
    start_time = Timex.to_unix(date)

    specialist_id = 1
    %{id: patient_id} = PatientProfile.Factory.insert(:patient)

    _basic_info =
      PatientProfile.Factory.insert(:basic_info, patient_id: patient_id)

    %{id: second_opinion_request_id} =
      Visits.Factory.insert(:us_board_second_opinion_request,
        patient_id: patient_id,
        patient_email: "krypto@doghouse.woof",
        status: :requested
      )

    {:ok, _existing_schedule} =
      DaySchedule.insert_or_update(
        %DaySchedule{specialist_id: specialist_id, date: date},
        [%{start_time: start_time, visit_type: :BOTH}],
        []
      )

    cmd = %TakeTimeslot{
      chosen_medical_category_id: 1,
      patient_id: patient_id,
      specialist_id: specialist_id,
      start_time: start_time,
      visit_type: :US_BOARD,
      us_board_request_id: second_opinion_request_id
    }

    assert {:ok, %Visits.PendingVisit{}} = TakeTimeslot.call(cmd)

    assert Repo.get_by(PatientRecord, %{
             type: "US_BOARD",
             with_specialist_id: specialist_id,
             patient_id: patient_id
           })
  end

  test "allows to take a :US_BOARD visit type timeslot with visit_type: :ONLINE" do
    date = ~D[2100-11-30]
    start_time = Timex.to_unix(date)

    specialist_id = 1
    %{id: patient_id} = PatientProfile.Factory.insert(:patient)

    _basic_info =
      PatientProfile.Factory.insert(:basic_info, patient_id: patient_id)

    %{id: second_opinion_request_id} =
      Visits.Factory.insert(:us_board_second_opinion_request,
        patient_id: patient_id,
        patient_email: "krypto@doghouse.woof",
        status: :requested
      )

    {:ok, _existing_schedule} =
      DaySchedule.insert_or_update(
        %DaySchedule{specialist_id: specialist_id, date: date},
        [%{start_time: start_time, visit_type: :ONLINE}],
        []
      )

    cmd = %TakeTimeslot{
      chosen_medical_category_id: 1,
      patient_id: patient_id,
      specialist_id: specialist_id,
      start_time: start_time,
      visit_type: :US_BOARD,
      us_board_request_id: second_opinion_request_id
    }

    assert {:ok, %Visits.PendingVisit{}} = TakeTimeslot.call(cmd)

    assert Repo.get_by(PatientRecord, %{
             type: "US_BOARD",
             with_specialist_id: specialist_id,
             patient_id: patient_id
           })
  end

  test "allows to take a :US_BOARD visit type timeslot with visit_type: :IN_OFFICE" do
    date = ~D[2100-11-30]
    start_time = Timex.to_unix(date)

    specialist_id = 1
    %{id: patient_id} = PatientProfile.Factory.insert(:patient)

    _basic_info =
      PatientProfile.Factory.insert(:basic_info, patient_id: patient_id)

    %{id: second_opinion_request_id} =
      Visits.Factory.insert(:us_board_second_opinion_request,
        patient_id: patient_id,
        patient_email: "krypto@doghouse.woof",
        status: :requested
      )

    {:ok, _existing_schedule} =
      DaySchedule.insert_or_update(
        %DaySchedule{specialist_id: specialist_id, date: date},
        [%{start_time: start_time, visit_type: :IN_OFFICE}],
        []
      )

    cmd = %TakeTimeslot{
      chosen_medical_category_id: 1,
      patient_id: patient_id,
      specialist_id: specialist_id,
      start_time: start_time,
      visit_type: :US_BOARD,
      us_board_request_id: second_opinion_request_id
    }

    assert {:ok, %Visits.PendingVisit{}} = TakeTimeslot.call(cmd)

    assert Repo.get_by(PatientRecord, %{
             type: "US_BOARD",
             with_specialist_id: specialist_id,
             patient_id: patient_id
           })
  end

  test "allows to take a :US_BOARD visit type timeslot with visit_type: :US_BOARD" do
    date = ~D[2100-11-30]
    start_time = Timex.to_unix(date)

    specialist_id = 1
    %{id: patient_id} = PatientProfile.Factory.insert(:patient)

    _basic_info =
      PatientProfile.Factory.insert(:basic_info, patient_id: patient_id)

    %{id: second_opinion_request_id} =
      Visits.Factory.insert(:us_board_second_opinion_request,
        patient_id: patient_id,
        patient_email: "krypto@doghouse.woof",
        status: :requested
      )

    {:ok, _existing_schedule} =
      DaySchedule.insert_or_update(
        %DaySchedule{specialist_id: specialist_id, date: date},
        [%{start_time: start_time, visit_type: :US_BOARD}],
        []
      )

    cmd = %TakeTimeslot{
      chosen_medical_category_id: 1,
      patient_id: patient_id,
      specialist_id: specialist_id,
      start_time: start_time,
      visit_type: :US_BOARD,
      us_board_request_id: second_opinion_request_id
    }

    assert {:ok, %Visits.PendingVisit{}} = TakeTimeslot.call(cmd)

    assert Repo.get_by(PatientRecord, %{
             type: "US_BOARD",
             with_specialist_id: specialist_id,
             patient_id: patient_id
           })
  end

  test "moves timeslot from free to taken with same id" do
    date = ~D[2100-11-30]
    [start_time] = start_times(date, 1)

    {:ok, existing_schedule} =
      DaySchedule.insert_or_update(
        %DaySchedule{specialist_id: 1, date: date},
        [%{start_time: start_time, visit_type: :ONLINE}],
        []
      )

    cmd = %TakeTimeslot{
      chosen_medical_category_id: 1,
      patient_id: 1,
      specialist_id: 1,
      start_time: start_time,
      visit_type: :ONLINE
    }

    assert {:ok, %Visits.PendingVisit{}} = TakeTimeslot.call(cmd)

    updated_schedule = Repo.get_by(DaySchedule, specialist_id: 1, date: date)

    assert updated_schedule.free_timeslots_count == existing_schedule.free_timeslots_count - 1
    assert updated_schedule.taken_timeslots_count == existing_schedule.taken_timeslots_count + 1

    assert List.first(updated_schedule.taken_timeslots).id ==
             List.first(existing_schedule.free_timeslots).id
  end

  test "triggers side-effects" do
    date = ~D[2100-11-30]
    [start_time] = start_times(date, 1)

    specialist_id = 1
    %{id: patient_id} = PatientProfile.Factory.insert(:patient)

    basic_info =
      PatientProfile.Factory.insert(:basic_info, patient_id: patient_id)

    {:ok, _existing_schedule} =
      DaySchedule.insert_or_update(
        %DaySchedule{specialist_id: specialist_id, date: date},
        [%{start_time: start_time, visit_type: :ONLINE}],
        []
      )

    cmd = %TakeTimeslot{
      chosen_medical_category_id: 1,
      patient_id: patient_id,
      specialist_id: specialist_id,
      start_time: start_time,
      visit_type: :ONLINE
    }

    {:ok, %Visits.PendingVisit{}} = TakeTimeslot.call(cmd)

    assert EMR.specialist_connected_with_patient?(specialist_id, patient_id)
    assert_called(ChannelBroadcast, :broadcast, [:pending_visits_update])

    assert_called(PushNotifications.Message, :send, [
      %PushNotifications.Message.VisitHasBeenScheduled{
        patient_id: ^patient_id,
        patient_first_name: _,
        patient_last_name: _,
        record_id: _,
        specialist_id: ^specialist_id,
        visit_start_time: ^start_time
      }
    ])

    refute_enqueued(
      worker: Mailers.MailerJobs,
      args: %{"type" => "VISIT_BOOKING_CONFIRMATION", "patient_email" => basic_info.email}
    )
  end
end
