defmodule EMR.PatientRecords.Timeline.Item.DisplayName do
  @item_types EMR.PatientRecords.Timeline.Item.item_types()

  @mapping EMR.PatientRecords.Timeline.Item.__changeset__()
           |> Enum.flat_map(fn
             {key, {:assoc, %{related: module}}} -> [{key, module}]
             _ -> []
           end)

  # sobelow_skip ["DOS.BinToAtom"]
  def get_for(timeline_item) do
    item_type =
      Enum.find(@item_types, fn item_type -> Map.get(timeline_item, :"#{item_type}_id") end)

    @mapping[item_type].display_name()
  end
end
