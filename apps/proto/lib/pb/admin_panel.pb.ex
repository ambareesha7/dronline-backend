defmodule Proto.AdminPanel.GetInternalSpecialistResponse.Type do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto3
  @type t :: integer | :UNKNOWN_TYPE | :GP | :NURSE

  field :UNKNOWN_TYPE, 0

  field :GP, 1

  field :NURSE, 2
end

defmodule Proto.AdminPanel.GetExternalSpecialistResponse.ApprovalStatus do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto3
  @type t :: integer | :UNKNOWN_STATUS | :WAITING | :VERIFIED | :REJECTED

  field :UNKNOWN_STATUS, 0

  field :WAITING, 1

  field :VERIFIED, 2

  field :REJECTED, 3
end

defmodule Proto.AdminPanel.VerifyExternalSpecialistRequest.Status do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto3
  @type t :: integer | :UNKNOWN | :VERIFIED | :REJECTED

  field :UNKNOWN, 0

  field :VERIFIED, 1

  field :REJECTED, 2
end

defmodule Proto.AdminPanel.InternalSpecialist.Type do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto3
  @type t :: integer | :UNKNOWN_TYPE | :GP | :NURSE

  field :UNKNOWN_TYPE, 0

  field :GP, 1

  field :NURSE, 2
end

defmodule Proto.AdminPanel.InternalSpecialist.Status do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto3
  @type t :: integer | :UNKNOWN_STATUS | :CREATED | :COMPLETED

  field :UNKNOWN_STATUS, 0

  field :CREATED, 1

  field :COMPLETED, 2
end

defmodule Proto.AdminPanel.ExternalSpecialist.ApprovalStatus do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto3
  @type t :: integer | :UNKNOWN_STATUS | :WAITING | :VERIFIED | :REJECTED

  field :UNKNOWN_STATUS, 0

  field :WAITING, 1

  field :VERIFIED, 2

  field :REJECTED, 3
end

defmodule Proto.AdminPanel.InternalSpecialistAccount.Type do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto3
  @type t :: integer | :UNKNOWN_TYPE | :GP | :NURSE | :EXTERNAL

  field :UNKNOWN_TYPE, 0

  field :GP, 1

  field :NURSE, 2

  field :EXTERNAL, 3
end

defmodule Proto.AdminPanel.AccountDeletion.Status do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto3
  @type t :: integer | :UNKNOWN_ACCOUNT_DELETION_STATUS | :PENDING | :DELETED

  field :UNKNOWN_ACCOUNT_DELETION_STATUS, 0

  field :PENDING, 1

  field :DELETED, 2
end

defmodule Proto.AdminPanel.AccountDeletion.Type do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto3
  @type t :: integer | :UNKNOWN_ACCOUNT_DELETION_TYPE | :PATIENT | :SPECIALIST

  field :UNKNOWN_ACCOUNT_DELETION_TYPE, 0

  field :PATIENT, 1

  field :SPECIALIST, 2
end

defmodule Proto.AdminPanel.GetExternalSpecialistsResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          external_specialists: [Proto.AdminPanel.ExternalSpecialist.t()],
          next_token: String.t()
        }

  defstruct [:external_specialists, :next_token]

  field :external_specialists, 1, repeated: true, type: Proto.AdminPanel.ExternalSpecialist
  field :next_token, 2, type: :string
end

defmodule Proto.AdminPanel.GetInternalSpecialistsResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          internal_specialists: [Proto.AdminPanel.InternalSpecialist.t()],
          next_token: String.t()
        }

  defstruct [:internal_specialists, :next_token]

  field :internal_specialists, 1, repeated: true, type: Proto.AdminPanel.InternalSpecialist
  field :next_token, 2, type: :string
end

defmodule Proto.AdminPanel.CreateInternalSpecialistRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          internal_specialist_account: Proto.AdminPanel.InternalSpecialistAccount.t() | nil
        }

  defstruct [:internal_specialist_account]

  field :internal_specialist_account, 1, type: Proto.AdminPanel.InternalSpecialistAccount
end

defmodule Proto.AdminPanel.CreateInternalSpecialistResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          internal_specialist_account: Proto.AdminPanel.InternalSpecialistAccount.t() | nil
        }

  defstruct [:internal_specialist_account]

  field :internal_specialist_account, 1, type: Proto.AdminPanel.InternalSpecialistAccount
end

defmodule Proto.AdminPanel.GetInternalSpecialistResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          type: Proto.AdminPanel.GetInternalSpecialistResponse.Type.t(),
          created_at: Proto.Generics.DateTime.t() | nil,
          completed_at: Proto.Generics.DateTime.t() | nil
        }

  defstruct [:type, :created_at, :completed_at]

  field :type, 1, type: Proto.AdminPanel.GetInternalSpecialistResponse.Type, enum: true
  field :created_at, 2, type: Proto.Generics.DateTime
  field :completed_at, 3, type: Proto.Generics.DateTime
end

defmodule Proto.AdminPanel.GetExternalSpecialistResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          joined_at: Proto.Generics.DateTime.t() | nil,
          approval_status_updated_at: Proto.Generics.DateTime.t() | nil,
          approval_status: Proto.AdminPanel.GetExternalSpecialistResponse.ApprovalStatus.t()
        }

  defstruct [:joined_at, :approval_status_updated_at, :approval_status]

  field :joined_at, 1, type: Proto.Generics.DateTime
  field :approval_status_updated_at, 2, type: Proto.Generics.DateTime

  field :approval_status, 3,
    type: Proto.AdminPanel.GetExternalSpecialistResponse.ApprovalStatus,
    enum: true
end

defmodule Proto.AdminPanel.VerifyExternalSpecialistRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          status: Proto.AdminPanel.VerifyExternalSpecialistRequest.Status.t()
        }

  defstruct [:status]

  field :status, 1, type: Proto.AdminPanel.VerifyExternalSpecialistRequest.Status, enum: true
end

defmodule Proto.AdminPanel.VerifyExternalSpecialistResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3
  @type t :: %__MODULE__{}

  defstruct []
end

defmodule Proto.AdminPanel.SendPasswordRecoveryRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3
  @type t :: %__MODULE__{}

  defstruct []
end

defmodule Proto.AdminPanel.SendPasswordRecoveryResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3
  @type t :: %__MODULE__{}

  defstruct []
end

defmodule Proto.AdminPanel.InternalSpecialist do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          id: non_neg_integer,
          title: Proto.Generics.Title.t(),
          first_name: String.t(),
          last_name: String.t(),
          type: Proto.AdminPanel.InternalSpecialist.Type.t(),
          email: String.t(),
          status: Proto.AdminPanel.InternalSpecialist.Status.t(),
          created_at: Proto.Generics.DateTime.t() | nil,
          completed_at: Proto.Generics.DateTime.t() | nil
        }

  defstruct [
    :id,
    :title,
    :first_name,
    :last_name,
    :type,
    :email,
    :status,
    :created_at,
    :completed_at
  ]

  field :id, 1, type: :uint64
  field :title, 3, type: Proto.Generics.Title, enum: true
  field :first_name, 4, type: :string
  field :last_name, 5, type: :string
  field :type, 6, type: Proto.AdminPanel.InternalSpecialist.Type, enum: true
  field :email, 8, type: :string
  field :status, 9, type: Proto.AdminPanel.InternalSpecialist.Status, enum: true
  field :created_at, 10, type: Proto.Generics.DateTime
  field :completed_at, 11, type: Proto.Generics.DateTime
end

defmodule Proto.AdminPanel.ExternalSpecialist do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          id: non_neg_integer,
          first_name: String.t(),
          last_name: String.t(),
          image_url: String.t(),
          medical_categories: [Proto.MedicalCategories.MedicalCategoryBase.t()],
          approval_status: Proto.AdminPanel.ExternalSpecialist.ApprovalStatus.t(),
          joined_at: Proto.Generics.DateTime.t() | nil,
          approval_status_updated_at: Proto.Generics.DateTime.t() | nil,
          email: String.t()
        }

  defstruct [
    :id,
    :first_name,
    :last_name,
    :image_url,
    :medical_categories,
    :approval_status,
    :joined_at,
    :approval_status_updated_at,
    :email
  ]

  field :id, 1, type: :uint64
  field :first_name, 4, type: :string
  field :last_name, 5, type: :string
  field :image_url, 6, type: :string
  field :medical_categories, 7, repeated: true, type: Proto.MedicalCategories.MedicalCategoryBase
  field :approval_status, 8, type: Proto.AdminPanel.ExternalSpecialist.ApprovalStatus, enum: true
  field :joined_at, 9, type: Proto.Generics.DateTime
  field :approval_status_updated_at, 10, type: Proto.Generics.DateTime
  field :email, 11, type: :string
end

defmodule Proto.AdminPanel.InternalSpecialistAccount do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          email: String.t(),
          type: Proto.AdminPanel.InternalSpecialistAccount.Type.t()
        }

  defstruct [:email, :type]

  field :email, 2, type: :string
  field :type, 4, type: Proto.AdminPanel.InternalSpecialistAccount.Type, enum: true
end

defmodule Proto.AdminPanel.FetchUSBoardSpecialistsResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          specialists: [Proto.AdminPanel.USBoardSpecialist.t()]
        }

  defstruct [:specialists]

  field :specialists, 1, repeated: true, type: Proto.AdminPanel.USBoardSpecialist
end

defmodule Proto.AdminPanel.USBoardSpecialist do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          specialist_id: non_neg_integer,
          first_name: String.t(),
          last_name: String.t(),
          image_url: String.t(),
          phone_number: String.t(),
          medical_title: Proto.Generics.MedicalTitle.t()
        }

  defstruct [:specialist_id, :first_name, :last_name, :image_url, :phone_number, :medical_title]

  field :specialist_id, 1, type: :uint64
  field :first_name, 2, type: :string
  field :last_name, 3, type: :string
  field :image_url, 4, type: :string
  field :phone_number, 5, type: :string
  field :medical_title, 6, type: Proto.Generics.MedicalTitle, enum: true
end

defmodule Proto.AdminPanel.USBoardAssignSpecialistRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          specialist_id: non_neg_integer,
          request_id: String.t()
        }

  defstruct [:specialist_id, :request_id]

  field :specialist_id, 1, type: :uint64
  field :request_id, 2, type: :string
end

defmodule Proto.AdminPanel.AccountDeletion do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          basic_info: {atom, any},
          id: String.t(),
          status: Proto.AdminPanel.AccountDeletion.Status.t(),
          type: Proto.AdminPanel.AccountDeletion.Type.t(),
          created_at: Proto.Generics.DateTime.t() | nil
        }

  defstruct [:basic_info, :id, :status, :type, :created_at]

  oneof :basic_info, 0
  field :id, 1, type: :string
  field :status, 2, type: Proto.AdminPanel.AccountDeletion.Status, enum: true
  field :type, 3, type: Proto.AdminPanel.AccountDeletion.Type, enum: true
  field :created_at, 4, type: Proto.Generics.DateTime
  field :patient_basic_info, 5, type: Proto.PatientProfile.BasicInfo, oneof: 0
  field :specialist_basic_info, 6, type: Proto.SpecialistProfile.BasicInfo, oneof: 0
end

defmodule Proto.AdminPanel.GetAccountDeletionsResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          account_deletions: [Proto.AdminPanel.AccountDeletion.t()]
        }

  defstruct [:account_deletions]

  field :account_deletions, 1, repeated: true, type: Proto.AdminPanel.AccountDeletion
end
