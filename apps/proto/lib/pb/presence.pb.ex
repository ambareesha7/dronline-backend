defmodule Proto.Presence.PresenceState do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          presences: [Proto.Presence.Presence.t()]
        }

  defstruct [:presences]

  field :presences, 1, repeated: true, type: Proto.Presence.Presence
end

defmodule Proto.Presence.PresenceDiff do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          joins: [Proto.Presence.Presence.t()],
          leaves: [Proto.Presence.Presence.t()]
        }

  defstruct [:joins, :leaves]

  field :joins, 1, repeated: true, type: Proto.Presence.Presence
  field :leaves, 2, repeated: true, type: Proto.Presence.Presence
end

defmodule Proto.Presence.Presence do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          id: non_neg_integer,
          metadata: [Proto.Presence.Metadata.t()]
        }

  defstruct [:id, :metadata]

  field :id, 1, type: :uint64
  field :metadata, 2, repeated: true, type: Proto.Presence.Metadata
end

defmodule Proto.Presence.Metadata do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          phx_ref: String.t()
        }

  defstruct [:phx_ref]

  field :phx_ref, 1, type: :string
end
