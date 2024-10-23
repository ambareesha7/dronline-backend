defmodule Proto.PanelAuthentication.LoginResponse.Type do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto3
  @type t :: integer | :UNKNOWN | :GP | :NURSE | :EXTERNAL

  field :UNKNOWN, 0

  field :GP, 1

  field :NURSE, 2

  field :EXTERNAL, 4
end

defmodule Proto.PanelAuthentication.LoginResponse.ApprovalStatus do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto3
  @type t :: integer | :UNKNOWN_STATUS | :WAITING | :VERIFIED | :REJECTED

  field :UNKNOWN_STATUS, 0

  field :WAITING, 1

  field :VERIFIED, 2

  field :REJECTED, 3
end

defmodule Proto.PanelAuthentication.LoginRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          email: String.t(),
          password: String.t()
        }

  defstruct [:email, :password]

  field :email, 1, type: :string
  field :password, 2, type: :string
end

defmodule Proto.PanelAuthentication.LoginResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          auth_token: String.t(),
          type: Proto.PanelAuthentication.LoginResponse.Type.t(),
          active_package_type: String.t()
        }

  defstruct [:auth_token, :type, :active_package_type]

  field :auth_token, 1, type: :string
  field :type, 2, type: Proto.PanelAuthentication.LoginResponse.Type, enum: true
  field :active_package_type, 3, type: :string
end

defmodule Proto.PanelAuthentication.SendPasswordRecoveryRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          email: String.t()
        }

  defstruct [:email]

  field :email, 1, type: :string
end

defmodule Proto.PanelAuthentication.SendPasswordRecoveryResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3
  @type t :: %__MODULE__{}

  defstruct []
end

defmodule Proto.PanelAuthentication.RecoverPasswordRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          password_recovery_token: String.t(),
          new_password: String.t()
        }

  defstruct [:password_recovery_token, :new_password]

  field :password_recovery_token, 1, type: :string
  field :new_password, 2, type: :string
end

defmodule Proto.PanelAuthentication.RecoverPasswordResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3
  @type t :: %__MODULE__{}

  defstruct []
end

defmodule Proto.PanelAuthentication.SignupRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          email: String.t(),
          password: String.t()
        }

  defstruct [:email, :password]

  field :email, 2, type: :string
  field :password, 3, type: :string
end

defmodule Proto.PanelAuthentication.SignupResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3
  @type t :: %__MODULE__{}

  defstruct []
end

defmodule Proto.PanelAuthentication.VerifyRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          verification_token: String.t()
        }

  defstruct [:verification_token]

  field :verification_token, 1, type: :string
end

defmodule Proto.PanelAuthentication.VerifyResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          auth_token: String.t()
        }

  defstruct [:auth_token]

  field :auth_token, 1, type: :string
end

defmodule Proto.PanelAuthentication.ChangePasswordRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          password: String.t()
        }

  defstruct [:password]

  field :password, 1, type: :string
end

defmodule Proto.PanelAuthentication.ChangePasswordResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3
  @type t :: %__MODULE__{}

  defstruct []
end

defmodule Proto.PanelAuthentication.ConfirmPasswordChangeRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          confirmation_token: String.t()
        }

  defstruct [:confirmation_token]

  field :confirmation_token, 1, type: :string
end

defmodule Proto.PanelAuthentication.ConfirmPasswordChangeResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3
  @type t :: %__MODULE__{}

  defstruct []
end

defmodule Proto.PanelAuthentication.SendSpecialistAccountDeletionRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3
  @type t :: %__MODULE__{}

  defstruct []
end
