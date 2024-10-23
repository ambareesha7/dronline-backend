defmodule Calls.PendingNurseToGPCalls.CommandsTest do
  use Postgres.DataCase, async: true
  import Mockery.Assertions

  alias EMR.PatientRecords.MedicalSummary.PendingSummary

  defp prepare_call_gp_command do
    patient = PatientProfile.Factory.insert(:patient)
    nurse = Authentication.Factory.insert(:specialist, type: "NURSE")
    record = EMR.Factory.insert(:automatic_record, patient_id: patient.id)

    %Calls.PendingNurseToGPCalls.Commands.CallGP{
      nurse_id: nurse.id,
      patient_id: patient.id,
      record_id: record.id
    }
  end

  defp prepare_cancel_call_to_gp_command(nurse_id) do
    %Calls.PendingNurseToGPCalls.Commands.CancelCallToGP{
      nurse_id: nurse_id
    }
  end

  defp prepare_answer_call_from_nurse_command(nurse_id) do
    gp = Authentication.Factory.insert(:specialist, type: "GP")

    %Calls.PendingNurseToGPCalls.Commands.AnswerCallFromNurse{
      gp_id: gp.id,
      nurse_id: nurse_id
    }
  end

  describe "call_gp/1" do
    test "add the nurse to queue" do
      cmd = prepare_call_gp_command()

      assert :ok = Calls.PendingNurseToGPCalls.Commands.call_gp(cmd)
      assert {:ok, [pending_call]} = Calls.PendingNurseToGPCalls.fetch()
      assert pending_call.nurse_id == cmd.nurse_id
    end

    test "doesn't allow to add the nurse to queue twice" do
      cmd = prepare_call_gp_command()

      assert :ok = Calls.PendingNurseToGPCalls.Commands.call_gp(cmd)
      assert {:ok, [pending_call]} = Calls.PendingNurseToGPCalls.fetch()
      assert pending_call.nurse_id == cmd.nurse_id

      assert {:error, changeset} = Calls.PendingNurseToGPCalls.Commands.call_gp(cmd)

      assert {"the nurse is already in queue", _details} =
               Keyword.get(changeset.errors, :nurse_id)
    end

    test "broadcast queue update on success" do
      cmd = prepare_call_gp_command()

      :ok = Calls.PendingNurseToGPCalls.Commands.call_gp(cmd)
      assert_called(Calls.ChannelBroadcast, :broadcast, [:pending_nurse_to_gp_calls_update])
    end
  end

  describe "cancel_call_to_gp/1" do
    test "removes the nurse from queue" do
      cmd = prepare_call_gp_command()

      :ok = Calls.PendingNurseToGPCalls.Commands.call_gp(cmd)
      assert {:ok, [pending_call]} = Calls.PendingNurseToGPCalls.fetch()
      assert pending_call.nurse_id == cmd.nurse_id

      cmd = prepare_cancel_call_to_gp_command(cmd.nurse_id)
      assert :ok = Calls.PendingNurseToGPCalls.Commands.cancel_call_to_gp(cmd)
      assert {:ok, []} = Calls.PendingNurseToGPCalls.fetch()
    end

    test "returns ok when the nurse isn't in queue" do
      cmd = prepare_cancel_call_to_gp_command(1337)
      assert :ok = Calls.PendingNurseToGPCalls.Commands.cancel_call_to_gp(cmd)
    end

    test "broadcasts queue update on success" do
      cmd = prepare_call_gp_command()
      :ok = Calls.PendingNurseToGPCalls.Commands.call_gp(cmd)

      cmd = prepare_cancel_call_to_gp_command(cmd.nurse_id)
      :ok = Calls.PendingNurseToGPCalls.Commands.cancel_call_to_gp(cmd)
      assert_called(Calls.ChannelBroadcast, :broadcast, [:pending_nurse_to_gp_calls_update], 2)
    end
  end

  describe "answer_call_from_nurse/1" do
    test "removes the nurse from queue" do
      cmd = prepare_call_gp_command()

      :ok = Calls.PendingNurseToGPCalls.Commands.call_gp(cmd)
      assert {:ok, [pending_call]} = Calls.PendingNurseToGPCalls.fetch()
      assert pending_call.nurse_id == cmd.nurse_id

      cmd = prepare_answer_call_from_nurse_command(cmd.nurse_id)
      assert :ok = Calls.PendingNurseToGPCalls.Commands.answer_call_from_nurse(cmd)
      assert {:ok, []} = Calls.PendingNurseToGPCalls.fetch()
    end

    test "returns error when the nurse isn't in queue" do
      cmd = prepare_answer_call_from_nurse_command(1337)

      assert {:error, :nurse_is_not_in_queue} =
               Calls.PendingNurseToGPCalls.Commands.answer_call_from_nurse(cmd)
    end

    test "broadcasts queue update on success" do
      cmd = prepare_call_gp_command()
      :ok = Calls.PendingNurseToGPCalls.Commands.call_gp(cmd)

      cmd = prepare_answer_call_from_nurse_command(cmd.nurse_id)
      :ok = Calls.PendingNurseToGPCalls.Commands.answer_call_from_nurse(cmd)
      assert_called(Calls.ChannelBroadcast, :broadcast, [:pending_nurse_to_gp_calls_update], 2)
    end

    test "pushes messages to gp and nurse on success" do
      cmd = prepare_call_gp_command()
      :ok = Calls.PendingNurseToGPCalls.Commands.call_gp(cmd)

      cmd = prepare_answer_call_from_nurse_command(cmd.nurse_id)
      :ok = Calls.PendingNurseToGPCalls.Commands.answer_call_from_nurse(cmd)

      nurse_id = cmd.nurse_id
      gp_id = cmd.gp_id

      assert_called(Calls.ChannelBroadcast, :push, [
        %{topic: "nurse", payload: %{nurse_id: ^nurse_id}}
      ])

      assert_called(Calls.ChannelBroadcast, :push, [%{topic: "gp", payload: %{gp_id: ^gp_id}}])
    end

    test "creates PendingSummary on successful answer call from nurse" do
      cmd = prepare_call_gp_command()
      :ok = Calls.PendingNurseToGPCalls.Commands.call_gp(cmd)
      record_id = cmd.record_id
      patient_id = cmd.patient_id

      cmd = prepare_answer_call_from_nurse_command(cmd.nurse_id)
      :ok = Calls.PendingNurseToGPCalls.Commands.answer_call_from_nurse(cmd)

      gp_id = cmd.gp_id

      assert %PendingSummary{patient_id: ^patient_id, record_id: ^record_id} =
               PendingSummary.get_by_specialist_id(gp_id)
    end
  end
end
