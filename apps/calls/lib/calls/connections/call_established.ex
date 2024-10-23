defmodule Calls.Connections.CallEstablished do
  @moduledoc """
  Handles established calls.

  It creates twilio room, twilio tokens and sends broadcasts to channels.
  """

  import Mockery.Macro

  require Logger

  defmacrop opentok do
    quote do: mockable(OpenTok, by: OpenTokMock)
  end

  def handle_call_established(
        %{record_id: record_id, call_id: _call_id, patient_id: patient_id, gp_id: gp_id} = args
      ) do
    _ = Logger.info(fn -> "Calls.Connections.CallEstablished: #{inspect(args)}" end)

    with {:ok, session_id} <- opentok().create_session(record_id),
         {:ok, :send} <- create_and_send_tokens(args, session_id, record_id) do
      cmd = %EMR.PatientRecords.Timeline.Commands.CreateCallItem{
        patient_id: patient_id,
        record_id: record_id,
        specialist_id: gp_id
      }

      _ = EMR.create_call_timeline_item(cmd)

      :ok
    end
  end

  defp create_and_send_tokens(args, session_id, timeline_id) do
    patient_token = OpenTok.generate_session_token(session_id)
    gp_token = OpenTok.generate_session_token(session_id)

    :ok = broadcast_to_gp(args, session_id, gp_token, timeline_id)
    :ok = broadcast_to_patient(args, session_id, patient_token)

    {:ok, :send}
  end

  defp broadcast_to_gp(args, session_id, token, timeline_id) do
    %{patient_id: patient_id, gp_id: gp_id, call_id: call_id} = args

    Calls.ChannelBroadcast.push(%{
      topic: "gp",
      event: "call_established",
      payload: %{
        proto: %Proto.Calls.CallEstablished{
          token: token,
          session_id: session_id,
          patient_id: patient_id,
          record_id: timeline_id,
          api_key: api_key(),
          call_id: call_id
        },
        gp_id: gp_id
      }
    })
  end

  defp broadcast_to_patient(args, session_id, token) do
    %{patient_id: patient_id, call_id: call_id} = args

    Calls.ChannelBroadcast.push(%{
      topic: "patient",
      event: "call_established",
      payload: %{
        proto: %Proto.Calls.CallEstablished{
          token: token,
          session_id: session_id,
          api_key: api_key(),
          call_id: call_id
        },
        patient_id: patient_id
      }
    })
  end

  defp api_key, do: Application.get_env(:opentok, :api_key)
end
