defmodule Proto.Devices.RegisterDeviceRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          firebase_token: String.t()
        }

  defstruct [:firebase_token]

  field :firebase_token, 1, type: :string
end

defmodule Proto.Devices.RegisterDeviceResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3
  @type t :: %__MODULE__{}

  defstruct []
end

defmodule Proto.Devices.UnregisterDeviceRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          firebase_token: String.t()
        }

  defstruct [:firebase_token]

  field :firebase_token, 1, type: :string
end

defmodule Proto.Devices.UnregisterDeviceResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3
  @type t :: %__MODULE__{}

  defstruct []
end

defmodule Proto.Devices.RegisterIOSDeviceRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          device_token: String.t()
        }

  defstruct [:device_token]

  field :device_token, 1, type: :string
end

defmodule Proto.Devices.RegisterIOSDeviceResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3
  @type t :: %__MODULE__{}

  defstruct []
end

defmodule Proto.Devices.UnregisterIOSDeviceRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          device_token: String.t()
        }

  defstruct [:device_token]

  field :device_token, 1, type: :string
end

defmodule Proto.Devices.UnregisterIOSDeviceResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3
  @type t :: %__MODULE__{}

  defstruct []
end
