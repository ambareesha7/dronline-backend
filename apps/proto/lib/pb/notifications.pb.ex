defmodule Proto.Notifications.GetNotificationsResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          notifications: [Proto.Notifications.Notification.t()],
          specialists: [Proto.Generics.Specialist.t()],
          unread_notifications_counter: non_neg_integer,
          next_token: String.t()
        }

  defstruct [:notifications, :specialists, :unread_notifications_counter, :next_token]

  field :notifications, 1, repeated: true, type: Proto.Notifications.Notification
  field :specialists, 2, repeated: true, type: Proto.Generics.Specialist
  field :unread_notifications_counter, 3, type: :uint32
  field :next_token, 4, type: :string
end

defmodule Proto.Notifications.NotificationsCounterResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          unread_notifications_counter: non_neg_integer
        }

  defstruct [:unread_notifications_counter]

  field :unread_notifications_counter, 1, type: :uint32
end

defmodule Proto.Notifications.MarkAllNotificationsAsReadResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3
  @type t :: %__MODULE__{}

  defstruct []
end

defmodule Proto.Notifications.NewNotification do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          notification: Proto.Notifications.Notification.t() | nil,
          specialists: [Proto.Generics.Specialist.t()],
          unread_notifications_counter: non_neg_integer
        }

  defstruct [:notification, :specialists, :unread_notifications_counter]

  field :notification, 1, type: Proto.Notifications.Notification
  field :specialists, 2, repeated: true, type: Proto.Generics.Specialist
  field :unread_notifications_counter, 3, type: :uint32
end

defmodule Proto.Notifications.Notification do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          type: {atom, any},
          id: String.t(),
          created_at: non_neg_integer,
          read: boolean
        }

  defstruct [:type, :id, :created_at, :read]

  oneof :type, 0
  field :id, 1, type: :string
  field :created_at, 2, type: :uint64
  field :read, 3, type: :bool

  field :timeline_item_comment_notification, 4,
    type: Proto.Notifications.TimelineItemCommentNotification,
    oneof: 0
end

defmodule Proto.Notifications.TimelineItemCommentNotification do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          patient_id: non_neg_integer,
          record_id: non_neg_integer,
          timeline_item_id: String.t(),
          timeline_item_comment: Proto.EMR.TimelineItemComment.t() | nil,
          commented_on: String.t()
        }

  defstruct [:patient_id, :record_id, :timeline_item_id, :timeline_item_comment, :commented_on]

  field :patient_id, 1, type: :uint64
  field :record_id, 2, type: :uint64
  field :timeline_item_id, 3, type: :string
  field :timeline_item_comment, 4, type: Proto.EMR.TimelineItemComment
  field :commented_on, 5, type: :string
end

defmodule Proto.Notifications.GetPatientNotificationsResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          notifications: [Proto.Notifications.PatientNotification.t()],
          specialists: [Proto.Generics.Specialist.t()],
          next_token: String.t()
        }

  defstruct [:notifications, :specialists, :next_token]

  field :notifications, 1, repeated: true, type: Proto.Notifications.PatientNotification
  field :specialists, 2, repeated: true, type: Proto.Generics.Specialist
  field :next_token, 3, type: :string
end

defmodule Proto.Notifications.PatientNotification do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          type: {atom, any},
          id: String.t(),
          created_at: non_neg_integer,
          read: boolean
        }

  defstruct [:type, :id, :created_at, :read]

  oneof :type, 0
  field :id, 1, type: :string
  field :created_at, 2, type: :uint64
  field :read, 3, type: :bool

  field :medical_summary_submitted_notification, 4,
    type: Proto.Notifications.MedicalSummarySubmittedNotification,
    oneof: 0

  field :tests_ordered_notification, 5,
    type: Proto.Notifications.TestsOrderedNotification,
    oneof: 0

  field :medications_assigned_notification, 6,
    type: Proto.Notifications.MedicationsAssignedNotification,
    oneof: 0
end

defmodule Proto.Notifications.MedicalSummarySubmittedNotification.MedicalSummary do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          id: non_neg_integer,
          record_id: non_neg_integer
        }

  defstruct [:id, :record_id]

  field :id, 1, type: :uint64
  field :record_id, 2, type: :uint64
end

defmodule Proto.Notifications.MedicalSummarySubmittedNotification do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          specialist_id: non_neg_integer,
          medical_summary:
            Proto.Notifications.MedicalSummarySubmittedNotification.MedicalSummary.t() | nil
        }

  defstruct [:specialist_id, :medical_summary]

  field :specialist_id, 1, type: :uint64

  field :medical_summary, 2,
    type: Proto.Notifications.MedicalSummarySubmittedNotification.MedicalSummary
end

defmodule Proto.Notifications.TestsOrderedNotification.TestsBundle do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          id: non_neg_integer,
          record_id: non_neg_integer
        }

  defstruct [:id, :record_id]

  field :id, 1, type: :uint64
  field :record_id, 2, type: :uint64
end

defmodule Proto.Notifications.TestsOrderedNotification do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          specialist_id: non_neg_integer,
          tests_bundle: Proto.Notifications.TestsOrderedNotification.TestsBundle.t() | nil
        }

  defstruct [:specialist_id, :tests_bundle]

  field :specialist_id, 1, type: :uint64
  field :tests_bundle, 2, type: Proto.Notifications.TestsOrderedNotification.TestsBundle
end

defmodule Proto.Notifications.MedicationsAssignedNotification.MedicationsBundle do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          id: non_neg_integer,
          record_id: non_neg_integer
        }

  defstruct [:id, :record_id]

  field :id, 1, type: :uint64
  field :record_id, 2, type: :uint64
end

defmodule Proto.Notifications.MedicationsAssignedNotification do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          specialist_id: non_neg_integer,
          medications_bundle:
            Proto.Notifications.MedicationsAssignedNotification.MedicationsBundle.t() | nil
        }

  defstruct [:specialist_id, :medications_bundle]

  field :specialist_id, 1, type: :uint64

  field :medications_bundle, 2,
    type: Proto.Notifications.MedicationsAssignedNotification.MedicationsBundle
end
