defmodule Calls.PendingNurseToGPCalls.Events.CallEstablished do
  @type t :: %__MODULE__{
          record_id: pos_integer,
          gp_id: pos_integer,
          patient_id: pos_integer
        }

  @fields [:gp_id, :patient_id, :record_id]

  @enforce_keys @fields
  defstruct @fields
end
