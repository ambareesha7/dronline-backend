defmodule Triage.CommandsTest do
  use Postgres.DataCase, async: true
  import Mockery
  import Mockery.Assertions

  alias EMR.PatientRecords.MedicalSummary.PendingSummary
  alias Triage.Commands

  defp request_dispatch_to_patient_cmd(patient_id \\ PatientProfile.Factory.insert(:patient).id) do
    record = EMR.Factory.insert(:manual_record, patient_id: patient_id)
    gp = Authentication.Factory.insert(:specialist, type: "GP")

    %Triage.Commands.RequestDispatchToPatient{
      patient_id: patient_id,
      patient_location_address: %{
        city: "Dubai",
        country: "United Arab Emirates",
        building_number: "1",
        postal_code: "2",
        street_name: "3"
      },
      record_id: record.id,
      region: "united-arab-emirates-dubai",
      request_id: UUID.uuid4(),
      requester_id: gp.id
    }
  end

  defp take_pending_dispatch_cmd(request_id, nurse_id) do
    %Triage.Commands.TakePendingDispatch{
      nurse_id: nurse_id,
      request_id: request_id
    }
  end

  defp end_dispatch_cmd(request_id, nurse_id) do
    %Triage.Commands.EndDispatch{
      nurse_id: nurse_id,
      request_id: request_id
    }
  end

  describe "request_dispatch_to_patient/1" do
    test "creates patient_waiting_for_dispatch database entry" do
      cmd = request_dispatch_to_patient_cmd()

      assert {:ok, _} = Commands.request_dispatch_to_patient(cmd)
      assert {:ok, waiting_patient} = Repo.fetch_one(Triage.PatientWaitingForDispatch)
      assert waiting_patient.request_id == cmd.request_id
    end

    test "creates pending_dispatch database entry" do
      cmd = request_dispatch_to_patient_cmd()

      assert {:ok, _} = Commands.request_dispatch_to_patient(cmd)
      assert {:ok, pending_dispatch} = Repo.fetch_one(Triage.PendingDispatch)
      assert pending_dispatch.request_id == cmd.request_id
    end

    test "doesn't allow to request dispatch twice to same patient" do
      patient = PatientProfile.Factory.insert(:patient)
      cmd1 = request_dispatch_to_patient_cmd(patient.id)
      cmd2 = request_dispatch_to_patient_cmd(patient.id)

      {:ok, _} = Commands.request_dispatch_to_patient(cmd1)
      assert {:error, %Ecto.Changeset{}} = Commands.request_dispatch_to_patient(cmd2)
    end

    test "sends update to channels when succeeds" do
      cmd = request_dispatch_to_patient_cmd()

      assert {:ok, _} = Commands.request_dispatch_to_patient(cmd)
      assert_called(Triage.ChannelBroadcast, :broadcast, [:pending_dispatches_update])
    end
  end

  describe "take_pending_dispatch/1" do
    test "creates ongoing_dispatch database entry" do
      cmd = request_dispatch_to_patient_cmd()
      {:ok, _pending_dispatch} = Commands.request_dispatch_to_patient(cmd)

      nurse = Authentication.Factory.insert(:specialist, type: "NURSE")
      cmd = take_pending_dispatch_cmd(cmd.request_id, nurse.id)

      assert {:ok, _ongoing_dispatch} = Commands.take_pending_dispatch(cmd)
      assert {:ok, ongoing_dispatch} = Repo.fetch_one(Triage.OngoingDispatch)
      assert ongoing_dispatch.request_id == cmd.request_id
    end

    test "removes pending_dispatch database entry" do
      cmd = request_dispatch_to_patient_cmd()
      {:ok, _pending_dispatch} = Commands.request_dispatch_to_patient(cmd)

      nurse = Authentication.Factory.insert(:specialist, type: "NURSE")
      cmd = take_pending_dispatch_cmd(cmd.request_id, nurse.id)

      assert {:ok, _ongoing_dispatch} = Commands.take_pending_dispatch(cmd)
      assert {:error, :not_found} = Repo.fetch_one(Triage.PendingDispatch)
    end

    test "doesn't allow to accept nonexisting pending_dispatch" do
      cmd = request_dispatch_to_patient_cmd()
      {:ok, _pending_dispatch} = Commands.request_dispatch_to_patient(cmd)

      nurse1 = Authentication.Factory.insert(:specialist, type: "NURSE")
      nurse2 = Authentication.Factory.insert(:specialist, type: "NURSE")
      cmd1 = take_pending_dispatch_cmd(cmd.request_id, nurse1.id)
      cmd2 = take_pending_dispatch_cmd(cmd.request_id, nurse2.id)

      {:ok, _ongoing_dispatch} = Commands.take_pending_dispatch(cmd1)
      assert {:error, :not_found} = Commands.take_pending_dispatch(cmd2)
    end

    test "doesn't allow to accept already accepted pending_dispatch" do
      cmd = request_dispatch_to_patient_cmd()
      {:ok, pending_dispatch} = Commands.request_dispatch_to_patient(cmd)

      mock(Triage.PendingDispatch, [fetch_by_request_id: 1], {:ok, pending_dispatch})

      nurse1 = Authentication.Factory.insert(:specialist, type: "NURSE")
      nurse2 = Authentication.Factory.insert(:specialist, type: "NURSE")
      cmd1 = take_pending_dispatch_cmd(cmd.request_id, nurse1.id)
      cmd2 = take_pending_dispatch_cmd(cmd.request_id, nurse2.id)

      {:ok, _} = Commands.take_pending_dispatch(cmd1)
      assert {:error, %Ecto.Changeset{}} = Commands.take_pending_dispatch(cmd2)
    end

    test "sends update to channels when succeeds" do
      cmd = request_dispatch_to_patient_cmd()
      {:ok, _pending_dispatch} = Commands.request_dispatch_to_patient(cmd)

      nurse = Authentication.Factory.insert(:specialist, type: "NURSE")
      cmd = take_pending_dispatch_cmd(cmd.request_id, nurse.id)

      assert {:ok, _ongoing_dispatch} = Commands.take_pending_dispatch(cmd)
      assert_called(Triage.ChannelBroadcast, :broadcast, [:pending_dispatches_update])
    end

    test "sends notification to patient when succeeds" do
      cmd = request_dispatch_to_patient_cmd()
      {:ok, _pending_dispatch} = Commands.request_dispatch_to_patient(cmd)

      nurse = Authentication.Factory.insert(:specialist, type: "NURSE")
      cmd = take_pending_dispatch_cmd(cmd.request_id, nurse.id)

      assert {:ok, _ongoing_dispatch} = Commands.take_pending_dispatch(cmd)
      assert_called(PushNotifications.Message, :send)
    end

    test "creates PendingSummary on successful ongoing dispatch" do
      cmd = request_dispatch_to_patient_cmd()
      {:ok, _pending_dispatch} = Commands.request_dispatch_to_patient(cmd)

      nurse = Authentication.Factory.insert(:specialist, type: "NURSE")
      cmd = take_pending_dispatch_cmd(cmd.request_id, nurse.id)

      assert {:ok, ongoing_dispatch} = Commands.take_pending_dispatch(cmd)

      nurse_id = ongoing_dispatch.nurse_id
      patient_id = ongoing_dispatch.patient_id
      record_id = ongoing_dispatch.record_id

      assert %PendingSummary{record_id: ^record_id, patient_id: ^patient_id} =
               PendingSummary.get_by_specialist_id(nurse_id)
    end
  end

  describe "end_dispatch/1" do
    test "creates ended_dispatch database entry" do
      cmd = request_dispatch_to_patient_cmd()
      {:ok, _pending_dispatch} = Commands.request_dispatch_to_patient(cmd)

      nurse = Authentication.Factory.insert(:specialist, type: "NURSE")

      cmd = take_pending_dispatch_cmd(cmd.request_id, nurse.id)
      assert {:ok, _ongoing_dispatch} = Commands.take_pending_dispatch(cmd)

      cmd = end_dispatch_cmd(cmd.request_id, nurse.id)
      assert {:ok, _ended_dispatch} = Commands.end_dispatch(cmd)
      assert {:ok, ended_dispatch} = Repo.fetch_one(Triage.EndedDispatch)
      assert ended_dispatch.request_id == cmd.request_id
    end

    test "removes ongoing_dispatch dabatase entry" do
      cmd = request_dispatch_to_patient_cmd()
      {:ok, _pending_dispatch} = Commands.request_dispatch_to_patient(cmd)

      nurse = Authentication.Factory.insert(:specialist, type: "NURSE")

      cmd = take_pending_dispatch_cmd(cmd.request_id, nurse.id)
      assert {:ok, _ongoing_dispatch} = Commands.take_pending_dispatch(cmd)

      cmd = end_dispatch_cmd(cmd.request_id, nurse.id)
      assert {:ok, _ended_dispatch} = Commands.end_dispatch(cmd)
      assert {:error, :not_found} = Repo.fetch_one(Triage.OngoingDispatch)
    end

    test "removes patient_waiting_for_dispatch dabatase entry" do
      cmd = request_dispatch_to_patient_cmd()
      {:ok, _pending_dispatch} = Commands.request_dispatch_to_patient(cmd)

      nurse = Authentication.Factory.insert(:specialist, type: "NURSE")

      cmd = take_pending_dispatch_cmd(cmd.request_id, nurse.id)
      assert {:ok, _ongoing_dispatch} = Commands.take_pending_dispatch(cmd)

      cmd = end_dispatch_cmd(cmd.request_id, nurse.id)
      assert {:ok, _ended_dispatch} = Commands.end_dispatch(cmd)
      assert {:error, :not_found} = Repo.fetch_one(Triage.PatientWaitingForDispatch)
    end

    test "doesn't allow to end dipatch by unassigned nurse" do
      cmd = request_dispatch_to_patient_cmd()
      {:ok, _pending_dispatch} = Commands.request_dispatch_to_patient(cmd)

      nurse = Authentication.Factory.insert(:specialist, type: "NURSE")

      cmd = take_pending_dispatch_cmd(cmd.request_id, nurse.id)
      assert {:ok, _ongoing_dispatch} = Commands.take_pending_dispatch(cmd)

      other_nurse = Authentication.Factory.insert(:specialist, type: "NURSE")
      cmd = end_dispatch_cmd(cmd.request_id, other_nurse.id)
      assert {:error, :forbidden} = Commands.end_dispatch(cmd)
    end

    test "allows to end only existing ongoing dispatches" do
      cmd = end_dispatch_cmd("unexisting", 0)
      assert {:error, :not_found} = Commands.end_dispatch(cmd)
    end
  end
end
