defmodule Triage.Commands.TakePendingDispatch do
  @type t :: %__MODULE__{
          nurse_id: pos_integer,
          request_id: String.t()
        }

  @fields [:nurse_id, :request_id]

  @enforce_keys @fields
  defstruct @fields
end
