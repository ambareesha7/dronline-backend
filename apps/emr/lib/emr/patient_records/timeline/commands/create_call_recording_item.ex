defmodule EMR.PatientRecords.Timeline.Commands.CreateCallRecordingItem do
  @fields [
    :patient_id,
    :record_id,
    :session_id,
    :thumbnail_gcs_path,
    :video_s3_path,
    :created_at,
    :duration
  ]

  @enforce_keys @fields
  defstruct @fields
end
