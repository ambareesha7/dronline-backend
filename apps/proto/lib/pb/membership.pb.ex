defmodule Proto.Membership.VerifyResponse.Status do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto3
  @type t :: integer | :UNKNOWN | :PAID | :DECLINED

  field :UNKNOWN, 0

  field :PAID, 1

  field :DECLINED, 2
end

defmodule Proto.Membership.GetPackagesListResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          packages: [Proto.Membership.Package.t()]
        }

  defstruct [:packages]

  field :packages, 1, repeated: true, type: Proto.Membership.Package
end

defmodule Proto.Membership.Package.Feature do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          text: String.t(),
          bold: boolean,
          description: String.t()
        }

  defstruct [:text, :bold, :description]

  field :text, 1, type: :string
  field :bold, 2, type: :bool
  field :description, 3, type: :string
end

defmodule Proto.Membership.Package do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          name: String.t(),
          price: String.t(),
          features: [Proto.Membership.Package.Feature.t()],
          type: String.t(),
          missing_features: [Proto.Membership.Package.Feature.t()]
        }

  defstruct [:name, :price, :features, :type, :missing_features]

  field :name, 1, type: :string
  field :price, 2, type: :string
  field :features, 3, repeated: true, type: Proto.Membership.Package.Feature
  field :type, 4, type: :string
  field :missing_features, 5, repeated: true, type: Proto.Membership.Package.Feature
end

defmodule Proto.Membership.GetActivePackageResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          active_package: Proto.Membership.Package.t() | nil,
          expires_at: Proto.Generics.DateTime.t() | nil,
          next_package: Proto.Membership.Package.t() | nil
        }

  defstruct [:active_package, :expires_at, :next_package]

  field :active_package, 1, type: Proto.Membership.Package
  field :expires_at, 2, type: Proto.Generics.DateTime
  field :next_package, 3, type: Proto.Membership.Package
end

defmodule Proto.Membership.GetPendingSubscriptionResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          redirect_url: String.t()
        }

  defstruct [:redirect_url]

  field :redirect_url, 1, type: :string
end

defmodule Proto.Membership.SubscribeRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          type: String.t()
        }

  defstruct [:type]

  field :type, 1, type: :string
end

defmodule Proto.Membership.SubscribeResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          redirect_url: String.t()
        }

  defstruct [:redirect_url]

  field :redirect_url, 1, type: :string
end

defmodule Proto.Membership.VerifyRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          order_id: String.t()
        }

  defstruct [:order_id]

  field :order_id, 1, type: :string
end

defmodule Proto.Membership.VerifyResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          status: Proto.Membership.VerifyResponse.Status.t(),
          package: Proto.Membership.Package.t() | nil
        }

  defstruct [:status, :package]

  field :status, 1, type: Proto.Membership.VerifyResponse.Status, enum: true
  field :package, 2, type: Proto.Membership.Package
end

defmodule Proto.Membership.ActivePackageUpdate do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          type: String.t()
        }

  defstruct [:type]

  field :type, 1, type: :string
end
