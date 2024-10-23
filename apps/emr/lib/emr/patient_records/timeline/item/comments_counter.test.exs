defmodule EMR.PatientRecords.Timeline.Item.CommentsCounterTest do
  use Postgres.DataCase, async: true
  import Mockery.Assertions

  alias EMR.PatientRecords.Timeline.Item
  alias EMR.PatientRecords.Timeline.Item.CommentsCounter

  describe "refresh_comments_counter/1" do
    test "is called by creating timeline item comment and updates counter on timeline item" do
      patient = PatientProfile.Factory.insert(:patient)
      record = EMR.Factory.insert(:automatic_record, patient_id: patient.id)

      cmd = %EMR.PatientRecords.Timeline.Commands.CreateCallItem{
        patient_id: patient.id,
        record_id: record.id,
        specialist_id: 1
      }

      {:ok, item} = EMR.PatientRecords.Timeline.Item.create_call_item(cmd)

      assert item.comments_counter == 0
      item_id = item.id

      cmd = %EMR.PatientRecords.Timeline.Commands.CreateItemComment{
        body: "comment",
        commented_by_specialist_id: 1,
        commented_on: "HPI",
        patient_id: 1,
        record_id: 1,
        timeline_item_id: item_id
      }

      _ = EMR.create_timeline_item_comment(cmd)

      assert_called(CommentsCounter, :refresh_comments_counter, [^item_id])
      assert Repo.get(Item, item_id).comments_counter == 1
    end
  end
end
