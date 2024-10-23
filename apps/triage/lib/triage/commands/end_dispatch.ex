defmodule Triage.Commands.EndDispatch do
  @type t :: %__MODULE__{
          nurse_id: pos_integer,
          request_id: String.t()
        }

  @fields [:nurse_id, :request_id]

  @enforce_keys @fields
  defstruct @fields
end
