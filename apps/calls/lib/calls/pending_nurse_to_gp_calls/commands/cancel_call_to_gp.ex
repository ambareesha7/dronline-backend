defmodule Calls.PendingNurseToGPCalls.Commands.CancelCallToGP do
  @type t :: %__MODULE__{
          nurse_id: pos_integer
        }

  @fields [:nurse_id]

  @enforce_keys @fields
  defstruct @fields
end
