defmodule Calls.PendingNurseToGPCalls.Commands.CallGP do
  @type t :: %__MODULE__{
          nurse_id: pos_integer,
          record_id: pos_integer,
          patient_id: pos_integer
        }

  @fields [:nurse_id, :record_id, :patient_id]

  @enforce_keys @fields
  defstruct @fields
end
