defmodule EMR.PatientRecords.Timeline.Item.CommentTest do
  use Postgres.DataCase, async: true

  alias EMR.PatientRecords.Timeline.Item.Comment

  alias EMR.PatientRecords.Timeline.Commands.CreateItemComment

  @timeline_item_id "3c0abe99-7c16-435e-85c2-740ebea4501f"

  defp prepare_comment(body) do
    cmd = %CreateItemComment{
      body: body,
      commented_by_specialist_id: 1,
      commented_on: "HPI",
      patient_id: 1,
      record_id: 1,
      timeline_item_id: @timeline_item_id
    }

    {:ok, comment, _updated_comments_counter} = Comment.create(cmd)

    comment
  end

  describe "fetch_paginated/4" do
    test "returns correct entries when next token is missing" do
      comment1 = prepare_comment("A")
      _comment2 = prepare_comment("B")

      params = %{"limit" => "1"}

      {:ok, [%Comment{body: "B"}], _comments_counter, next_token} =
        Comment.fetch_paginated(1, 1, @timeline_item_id, params)

      assert next_token == NaiveDateTime.to_iso8601(comment1.inserted_at)
    end

    test "returns correct entries when next token is present" do
      comment1 = prepare_comment("A")
      _comment2 = prepare_comment("B")

      params = %{"limit" => "1", "next_token" => NaiveDateTime.to_iso8601(comment1.inserted_at)}

      {:ok, [%Comment{body: "A"}], _comments_counter, next_token} =
        Comment.fetch_paginated(1, 1, @timeline_item_id, params)

      assert next_token == ""
    end

    test "returns correct total comments counter" do
      _comment1 = prepare_comment("A")
      _comment2 = prepare_comment("B")
      _comment3 = prepare_comment("C")

      params = %{"limit" => "1"}

      {:ok, _, comments_counter, _next_token} =
        Comment.fetch_paginated(1, 1, @timeline_item_id, params)

      assert comments_counter == 3
    end
  end
end
