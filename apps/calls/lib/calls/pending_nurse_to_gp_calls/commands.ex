defmodule Calls.PendingNurseToGPCalls.Commands do
  import Mockery.Macro

  defp api_key, do: Application.get_env(:opentok, :api_key)

  defmacrop channel_broadcast do
    quote do: mockable(Calls.ChannelBroadcast, by: Calls.ChannelBroadcastMock)
  end

  defmacrop opentok do
    quote do: mockable(OpenTok, by: OpenTokMock)
  end

  def call_gp(%Calls.PendingNurseToGPCalls.Commands.CallGP{} = command) do
    params = Map.from_struct(command)

    with {:ok, _pending_call} <- Calls.PendingNurseToGPCalls.add_call(params) do
      :ok = broadcast_update()
    end
  end

  def cancel_call_to_gp(%Calls.PendingNurseToGPCalls.Commands.CancelCallToGP{} = command) do
    with {:ok, _pending_call} <- Calls.PendingNurseToGPCalls.remove_call(command.nurse_id) do
      :ok = broadcast_update()
    else
      {:error, :nurse_is_not_in_queue} -> :ok
    end
  end

  def answer_call_from_nurse(
        %Calls.PendingNurseToGPCalls.Commands.AnswerCallFromNurse{} = command
      ) do
    with {:ok, pending_call} <- Calls.PendingNurseToGPCalls.remove_call(command.nurse_id) do
      :ok = push_call_established(command, pending_call)
      :ok = broadcast_update()
      :ok = create_medical_pending_summary(command, pending_call)
    end
  end

  defp broadcast_update do
    channel_broadcast().broadcast(:pending_nurse_to_gp_calls_update)

    :ok
  end

  defp create_medical_pending_summary(command, pending_call) do
    {:ok, :created} =
      EMR.PatientRecords.MedicalSummary.PendingSummary.create(
        pending_call.patient_id,
        pending_call.record_id,
        command.gp_id
      )

    :ok
  end

  defp push_call_established(command, pending_call) do
    {:ok, session_id} = opentok().create_session(pending_call.record_id)
    call_id = Calls.Call.start()

    push_call_established_to_nurse(call_id, session_id, pending_call, command)
    push_call_established_to_gp(call_id, session_id, pending_call, command)
  end

  defp push_call_established_to_nurse(call_id, session_id, pending_call, command) do
    token = OpenTok.generate_session_token(session_id)

    push_data = %{
      topic: "nurse",
      event: "call_established",
      payload: %{
        data: %{
          session_id: session_id,
          token: token,
          call_id: call_id,
          record_id: pending_call.record_id,
          api_key: api_key(),
          patient_id: pending_call.patient_id
        },
        nurse_id: command.nurse_id
      }
    }

    channel_broadcast().push(push_data)
  end

  defp push_call_established_to_gp(call_id, session_id, pending_call, command) do
    token = OpenTok.generate_session_token(session_id)

    push_data = %{
      topic: "gp",
      event: "call_established",
      payload: %{
        data: %{
          session_id: session_id,
          token: token,
          call_id: call_id,
          record_id: pending_call.record_id,
          api_key: api_key(),
          patient_id: pending_call.patient_id
        },
        gp_id: command.gp_id
      }
    }

    channel_broadcast().push(push_data)
  end
end
