defmodule EMR.PatientRecords.Timeline.Item.Comment do
  use Postgres.Schema
  use Postgres.Service

  import Mockery.Macro

  alias EMR.PatientRecords.Timeline.Commands.CreateItemComment
  alias EMR.PatientRecords.Timeline.Item.CommentsCounter

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "timeline_item_comments" do
    field :patient_id, :integer
    field :record_id, :integer
    field :timeline_item_id, :binary_id

    field :commented_by_specialist_id, :integer
    field :commented_on, :string
    field :body, :string

    timestamps()
  end

  defmacrop comments_counter do
    quote do: mockable(CommentsCounter)
  end

  defmacrop channel_broadcast do
    quote do: mockable(ChannelBroadcast, by: ChannelBroadcastMock)
  end

  @fields [
    :body,
    :commented_by_specialist_id,
    :commented_on,
    :patient_id,
    :record_id,
    :timeline_item_id
  ]

  @spec create(%CreateItemComment{}) ::
          {:ok, %__MODULE__{}, updated_comments_counter :: pos_integer}
          | {:error, Ecto.Changeset.t()}
  def create(%CreateItemComment{} = cmd) do
    params = Map.from_struct(cmd)

    %__MODULE__{}
    |> cast(params, @fields)
    |> validate_required(@fields)
    |> Repo.insert()
    |> case do
      {:ok, comment} ->
        {:ok, updated_comments_counter} =
          comments_counter().refresh_comments_counter(comment.timeline_item_id)

        broadcast_data = {:new_timeline_item_comment, comment, updated_comments_counter}
        channel_broadcast().broadcast(broadcast_data)

        notify_specialists(comment)

        {:ok, comment, updated_comments_counter}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  @spec fetch_paginated(pos_integer, pos_integer, String.t(), map) ::
          {:ok, [%__MODULE__{}], pos_integer, String.t()}
  def fetch_paginated(patient_id, record_id, timeline_item_id, params) do
    {:ok, result, next_token} =
      __MODULE__
      |> where(patient_id: ^patient_id)
      |> where(record_id: ^record_id)
      |> where(timeline_item_id: ^timeline_item_id)
      |> where(^Postgres.Option.next_token(params, :inserted_at, :desc))
      |> order_by(desc: :inserted_at)
      |> Repo.fetch_paginated(params, :inserted_at)

    {:ok, comments_counter} = CommentsCounter.refresh_comments_counter(timeline_item_id)

    {:ok, result, comments_counter, parse_next_token(next_token)}
  end

  defp parse_next_token(nil), do: ""
  defp parse_next_token(nt), do: NaiveDateTime.to_iso8601(nt)

  defp notify_specialists(comment) do
    specialists_involved_in_record =
      EMR.PatientRecords.InvolvedSpecialists.get_for_record(comment.patient_id, comment.record_id)

    specialists_to_be_notified =
      specialists_involved_in_record -- [comment.commented_by_specialist_id]

    :ok =
      NotificationsWrite.notify_specialists_about_timeline_item_comment(
        comment.id,
        specialists_to_be_notified
      )
  end
end
