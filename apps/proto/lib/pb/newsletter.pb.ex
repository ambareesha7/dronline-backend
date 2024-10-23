defmodule Proto.Newsletter.SubscribeRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          email: String.t(),
          phone_number: String.t()
        }

  defstruct [:email, :phone_number]

  field :email, 1, type: :string
  field :phone_number, 2, type: :string
end

defmodule Proto.Newsletter.SubscribeResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3
  @type t :: %__MODULE__{}

  defstruct []
end
