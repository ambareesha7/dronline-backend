defmodule Proto.Insurance.GetProvidersResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          providers: [Proto.Insurance.Provider.t()]
        }

  defstruct [:providers]

  field :providers, 1, repeated: true, type: Proto.Insurance.Provider
end

defmodule Proto.Insurance.Provider do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          id: non_neg_integer,
          name: String.t(),
          logo_url: String.t()
        }

  defstruct [:id, :name, :logo_url]

  field :id, 1, type: :uint32
  field :name, 2, type: :string
  field :logo_url, 3, type: :string
end
