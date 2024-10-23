defmodule EMR.PatientRecords.Timeline.ItemData.CallRecording do
  use Postgres.Schema
  use Postgres.Service

  alias EMR.PatientRecords.Timeline.Commands.CreateCallRecordingItem

  @behaviour EMR.PatientRecords.Timeline.ItemData

  schema "call_recordings" do
    field :video_gcs_path, :string
    field :video_s3_path, :string
    field :thumbnail_gcs_path, :string
    field :session_id, :string

    field :patient_id, :integer
    field :record_id, :integer

    field :created_at, :integer
    field :duration, :integer

    timestamps()
  end

  @fields [
    :patient_id,
    :record_id,
    :session_id,
    :thumbnail_gcs_path,
    :video_s3_path,
    :created_at,
    :duration
  ]
  def create(%CreateCallRecordingItem{} = cmd) do
    params = Map.from_struct(cmd)

    %__MODULE__{}
    |> cast(params, @fields)
    |> validate_required(@fields)
    |> Repo.insert()
  end

  @spec fetch_for_record(pos_integer, pos_integer, map) ::
          {:ok, [%__MODULE__{}], next_token :: pos_integer | nil}
  def fetch_for_record(patient_id, record_id, params) do
    __MODULE__
    |> where(patient_id: ^patient_id)
    |> where(record_id: ^record_id)
    |> where(^Postgres.Option.next_token(params, :id, :desc))
    |> order_by(desc: :id)
    |> Repo.fetch_paginated(params, :id)
  end

  @impl true
  def specialist_ids_in_item(%__MODULE__{}) do
    []
  end

  @impl true
  def display_name do
    "Call Recording"
  end
end
