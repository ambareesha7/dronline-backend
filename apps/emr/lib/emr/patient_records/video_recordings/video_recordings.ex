defmodule EMR.PatientRecords.VideoRecordings do
  @moduledoc """
  Because copying file from S3 to GCS was using too much memory for now we will use s3 directly
  """

  alias EMR.PatientRecords.VideoRecordings.TokboxSession

  @default_thumbnail_placeholder "/dronline-prod/images/placeholders/black.png"

  @spec process_video_recording_and_add_to_record(String.t(), String.t(), map) :: :ok
  def process_video_recording_and_add_to_record(archive_id, session_id, archive_info) do
    case TokboxSession.get_record_id_for_tokbox_session(session_id) do
      nil ->
        _ =
          Sentry.Context.set_extra_context(%{
            archive_id: archive_id,
            session_id: session_id,
            archive_info: archive_info
          })

        _ =
          Sentry.capture_message(
            "TokboxSession.get_record_id_for_tokbox_session/1 - no session found"
          )

        :ok

      record_id ->
        # {gcs_video_resource_path, gcs_image_resource_path} = move_video_to_gcs(archive_id)

        cmd = %EMR.PatientRecords.Timeline.Commands.CreateCallRecordingItem{
          patient_id: Postgres.Repo.get(EMR.PatientRecords.PatientRecord, record_id).patient_id,
          record_id: record_id,
          session_id: session_id,
          # thumbnail_gcs_path: gcs_image_resource_path,
          # video_gcs_path: gcs_video_resource_path
          thumbnail_gcs_path: @default_thumbnail_placeholder,
          video_s3_path: video_s3_path(archive_id),
          created_at: archive_info[:created_at],
          duration: archive_info[:duration]
        }

        with {:ok, _item} <- EMR.PatientRecords.Timeline.Item.create_call_recording_item(cmd) do
          :ok
        else
          error ->
            _ =
              Sentry.Context.set_extra_context(%{
                params: cmd,
                error: error
              })

            _ =
              Sentry.capture_message(
                "EMR.PatientRecords.Timeline.Item.create_call_recording_item/1 - error"
              )

            :error
        end
    end
  end

  defp video_s3_path(archive_id) do
    tokbox_id = Application.get_env(:emr, :tokbox_id)

    "#{tokbox_id}/#{archive_id}/archive.mp4"
  end

  def s3_download_url(path) do
    config = ExAws.Config.new(:s3)
    tokbox_aws_bucket = Application.get_env(:emr, :tokbox_aws_bucket)

    {:ok, url} =
      ExAws.S3.presigned_url(
        config,
        :GET,
        tokbox_aws_bucket,
        path,
        expires_in: 60
      )

    url
  end

  # defp move_video_to_gcs(archive_id) do
  #   file_path_base = "tokbox/videos/" <> UUID.uuid4() <> "/" <> archive_id
  #   {:ok, s3_video_download_url} = one_minute_s3_download_url(archive_id)
  #
  #   {:ok, gcs_video_upload_url, gcs_video_resource_path} =
  #     Upload.generate_private_upload_url(file_path_base <> "/archive.mp4", "video/mp4")
  #
  #   {:ok, gcs_image_upload_url, gcs_image_resource_path} =
  #     Upload.generate_private_upload_url(file_path_base <> "/thumbnail.jpg", "image/jpeg")
  #
  #   {:ok, %{status: 200, body: video_content}} = Tesla.get(s3_video_download_url)
  #
  #   {:ok, %{status: 200}} =
  #     Tesla.put(gcs_video_upload_url, video_content,
  #       headers: [{"content-type", "video/mp4"}, {"x-goog-acl", "private"}]
  #     )
  #
  #   case generate_thumbnail_content(video_content) do
  #     {:ok, image_content} ->
  #       {:ok, %{status: 200}} =
  #         Tesla.put(gcs_image_upload_url, image_content,
  #           headers: [{"content-type", "image/jpeg"}, {"x-goog-acl", "private"}]
  #         )
  #
  #       {gcs_video_resource_path, gcs_image_resource_path}
  #
  #     :error ->
  #       {gcs_video_resource_path, @default_thumbnail_placeholder}
  #   end
  # end
  #
  # defp one_minute_s3_download_url(archive_id) do
  #   config = ExAws.Config.new(:s3)
  #
  #   tokbox_aws_bucket = Application.get_env(:emr, :tokbox_aws_bucket)
  #   tokbox_id = Application.get_env(:emr, :tokbox_id)
  #
  #   {:ok, _url} =
  #     ExAws.S3.presigned_url(
  #       config,
  #       :GET,
  #       tokbox_aws_bucket,
  #       "#{tokbox_id}/#{archive_id}/archive.mp4",
  #       expires_in: 60
  #     )
  # end
  #
  # # sobelow_skip ["Traversal.FileModule"]
  # defp generate_thumbnail_content(video_content) do
  #   video_procesing_temp_dir = Application.get_env(:emr, :video_processing_temp_dir)
  #   tempfile_path = Path.join(video_procesing_temp_dir, UUID.uuid4())
  #
  #   try do
  #     _ = File.write(tempfile_path, video_content)
  #
  #     args = [
  #       "-i",
  #       tempfile_path,
  #       "-ss",
  #       "00:00:10.000",
  #       "-vframes",
  #       "1",
  #       "-f",
  #       "singlejpeg",
  #       "/dev/stdout",
  #       "-y",
  #       "-loglevel",
  #       "panic"
  #     ]
  #
  #     case System.cmd("ffmpeg", args) do
  #       {image_content, 0} when image_content != "" ->
  #         {:ok, image_content}
  #
  #       _ ->
  #         :error
  #     end
  #   after
  #     File.rm(tempfile_path)
  #   end
  # end
end
