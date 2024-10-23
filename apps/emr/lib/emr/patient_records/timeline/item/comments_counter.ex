defmodule EMR.PatientRecords.Timeline.Item.CommentsCounter do
  use Postgres.Service

  @spec refresh_comments_counter(String.t()) :: {:ok, pos_integer}
  def refresh_comments_counter(timeline_item_id) do
    current_comments_count =
      EMR.PatientRecords.Timeline.Item.Comment
      |> where(timeline_item_id: ^timeline_item_id)
      |> select(count())
      |> Repo.one()

    _ =
      EMR.PatientRecords.Timeline.Item
      |> where(id: ^timeline_item_id)
      |> Repo.update_all(set: [comments_counter: current_comments_count])

    {:ok, current_comments_count}
  end
end
