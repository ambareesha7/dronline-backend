defmodule EMR.PatientRecords.Timeline.Commands.CreateCallItem do
  @enforce_keys [:patient_id, :record_id, :specialist_id]
  defstruct [:medical_category_id, :patient_id, :record_id, :specialist_id]
end
