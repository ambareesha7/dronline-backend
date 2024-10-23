defmodule EMR.PatientRecords.TimelineTest do
  use Postgres.DataCase, async: true

  alias EMR.PatientRecords.Timeline

  describe "fetch_by_id/1" do
    test "returns error when id is invalid" do
      assert {:error, :not_found} =
               EMR.PatientRecords.Timeline.fetch_by_id(:rand.uniform(1_000_000))
    end

    test "returns empty list when there is timeline without items" do
      patient = PatientProfile.Factory.insert(:patient)
      record = EMR.Factory.insert(:automatic_record, patient_id: patient.id)
      _record = EMR.Factory.insert(:manual_record, patient_id: patient.id)

      assert {:ok, %{timeline_items: []}, []} = Timeline.fetch_by_id(record.id)
    end

    test "returns specialist and no timeline items, when there is a record with specialist_id" do
      %{id: specialist_id} = Authentication.Factory.insert(:specialist)

      patient = PatientProfile.Factory.insert(:patient)

      record =
        EMR.Factory.insert(:visit_record,
          patient_id: patient.id,
          specialist_id: specialist_id
        )

      assert {:ok, %{timeline_items: []}, [^specialist_id]} = Timeline.fetch_by_id(record.id)
    end

    test "returns preloaded items with preloaded content" do
      patient = PatientProfile.Factory.insert(:patient)
      specialist = Authentication.Factory.insert(:specialist)
      record = EMR.Factory.insert(:automatic_record, patient_id: patient.id)

      cmd = %EMR.PatientRecords.Timeline.Commands.CreateCallItem{
        patient_id: patient.id,
        record_id: record.id,
        specialist_id: specialist.id
      }

      {:ok, _call_item} = Timeline.Item.create_call_item(cmd)

      assert {:ok, timeline, specialist_ids} = Timeline.fetch_by_id(record.id)

      assert %{
               timeline_items: [
                 %Timeline.Item{
                   call: %Timeline.ItemData.Call{}
                 }
               ]
             } = timeline

      assert specialist.id in specialist_ids
    end

    test "returns preloaded items sorted from the newest" do
      patient = PatientProfile.Factory.insert(:patient)
      specialist = Authentication.Factory.insert(:specialist)
      record = EMR.Factory.insert(:automatic_record, patient_id: patient.id)

      cmd = %EMR.PatientRecords.Timeline.Commands.CreateCallItem{
        patient_id: patient.id,
        record_id: record.id,
        specialist_id: specialist.id
      }

      {:ok, first_call_item} = Timeline.Item.create_call_item(cmd)
      {:ok, second_call_item} = Timeline.Item.create_call_item(cmd)

      assert {:ok, timeline, _specialist_ids} = Timeline.fetch_by_id(record.id)

      assert List.first(timeline.timeline_items).id == second_call_item.id
      assert List.last(timeline.timeline_items).id == first_call_item.id
    end
  end
end
