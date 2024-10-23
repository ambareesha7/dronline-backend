defmodule Calls.PendingNurseToGPCalls.Commands.AnswerCallFromNurse do
  @type t :: %__MODULE__{
          nurse_id: pos_integer,
          gp_id: pos_integer
        }

  @enforce_keys [:nurse_id, :gp_id]
  defstruct [:nurse_id, :gp_id]
end
