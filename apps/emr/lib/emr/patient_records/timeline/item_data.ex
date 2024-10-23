defmodule EMR.PatientRecords.Timeline.ItemData do
  @callback display_name :: String.t()
  @callback specialist_ids_in_item(struct) :: [specialist_id :: pos_integer]
end
