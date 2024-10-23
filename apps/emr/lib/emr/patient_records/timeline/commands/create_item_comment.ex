defmodule EMR.PatientRecords.Timeline.Commands.CreateItemComment do
  @fields [
    :body,
    :commented_by_specialist_id,
    :commented_on,
    :patient_id,
    :record_id,
    :timeline_item_id
  ]

  @enforce_keys @fields
  defstruct @fields
end
