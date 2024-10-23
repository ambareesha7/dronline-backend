defmodule Proto.Authentication.LoginRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          firebase_token: String.t()
        }

  defstruct [:firebase_token]

  field :firebase_token, 1, type: :string
end

defmodule Proto.Authentication.LoginResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          auth_token: String.t()
        }

  defstruct [:auth_token]

  field :auth_token, 1, type: :string
end

defmodule Proto.Authentication.SendPatientAccountDeletionRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3
  @type t :: %__MODULE__{}

  defstruct []
end
