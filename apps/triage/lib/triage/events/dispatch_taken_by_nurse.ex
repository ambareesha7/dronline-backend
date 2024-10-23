defmodule Triage.Events.DispatchTakenByNurse do
  @fields [:nurse_id, :patient_id, :record_id]

  @enforce_keys @fields
  defstruct @fields
end
