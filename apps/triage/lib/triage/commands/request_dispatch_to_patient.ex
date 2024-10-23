defmodule Triage.Commands.RequestDispatchToPatient do
  @type t :: %__MODULE__{
          patient_id: pos_integer,
          patient_location_address: map,
          record_id: pos_integer,
          region: String.t(),
          request_id: String.t(),
          requester_id: pos_integer
        }

  @fields [
    :patient_id,
    :patient_location_address,
    :record_id,
    :region,
    :request_id,
    :requester_id
  ]

  @enforce_keys @fields
  defstruct @fields
end
