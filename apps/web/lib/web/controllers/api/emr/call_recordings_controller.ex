defmodule Web.Api.EMR.CallRecordingsController do
  use Web, :controller

  action_fallback Web.FallbackController

  def index(conn, params) do
    patient_id = conn.assigns.current_patient_id

    %{"record_id" => record_id} = params
    record_id = String.to_integer(record_id)

    {:ok, call_recordings, next_token} =
      EMR.fetch_call_recordings_for_record(patient_id, record_id, params)

    conn
    |> render("index.proto", %{
      call_recordings: call_recordings,
      next_token: next_token |> Web.ControllerHelper.next_token_to_string()
    })
  end
end

defmodule Web.Api.EMR.CallRecordingsView do
  use Web, :view

  def render("index.proto", %{call_recordings: call_recordings, next_token: next_token}) do
    %Proto.EMR.GetRecordCallRecordingsResponse{
      call_recordings: Enum.map(call_recordings, &Web.View.EMR.render_call_recording/1),
      next_token: next_token
    }
  end
end
