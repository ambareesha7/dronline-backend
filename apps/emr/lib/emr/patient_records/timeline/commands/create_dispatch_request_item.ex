defmodule EMR.PatientRecords.Timeline.Commands.CreateDispatchRequestItem do
  @fields [:patient_id, :patient_location_address, :record_id, :request_id, :requester_id]

  @enforce_keys @fields
  defstruct @fields
end
