defmodule Web.Webhooks.TokboxArchiveCallbackController do
  use Web, :controller

  require Logger

  def handle_callback(conn, params) do
    _ = Logger.info(fn -> inspect(params) end)

    handle_status_change(params["status"], params["id"], params["sessionId"])

    conn |> send_resp(202, "")
  end

  defp handle_status_change("uploaded", archive_id, session_id) do
    archive_info = get_archive_info(archive_id)
    EMR.process_video_recording_and_add_to_record(archive_id, session_id, archive_info)
  end

  defp handle_status_change(_other_status, _archive_id, _session_id) do
    :ok
  end

  defp get_archive_info(archive_id) do
    with {:ok, info} <- OpenTok.get_archive_information(archive_id) do
      info
    else
      _ -> %{}
    end
  end
end

# CALLBACK RESPONSE EXAMPLE
# %{
#   "certificate" => "",
#   "createdAt" => 1_565_715_089_000,
#   "duration" => 73,
#   "event" => "archive",
#   "hasAudio" => true,
#   "hasVideo" => true,
#   "height" => 480,
#   "id" => "1e9de2af-9cb0-4537-afbc-1dd1900555f3",
#   "name" => "",
#   "outputMode" => "composed",
#   "partnerId" => 46_281_112,
#   "password" => "",
#   "projectId" => 46_281_112,
#   "reason" => "session ended",
#   "resolution" => "640x480",
#   "sessionId" => "1_MX40NjI4MTExMn5-MTU2NTcxNTA4NTcxMH5mUXdIN3ArQ3EwNElpWVNwWkVPOFI2V1B-QX4",
#   "sha256sum" => "c28G76gw5RDF29wjNNBBlFOX96AbxXAIbjTYYBR9cFk=",
#   "size" => 1_347_546,
#   "status" => "uploaded",
#   "updatedAt" => 1_565_715_164_680,
#   "width" => 640
# }
