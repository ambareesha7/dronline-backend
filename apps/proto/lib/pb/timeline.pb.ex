defmodule Proto.Timeline.Specialist.Type do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto3
  @type t :: integer | :UNKNOWN | :GP | :NURSE | :EXTERNAL

  field :UNKNOWN, 0

  field :GP, 1

  field :NURSE, 2

  field :EXTERNAL, 4
end

defmodule Proto.Timeline.GetTimelineResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          timeline: Proto.Timeline.Timeline.t() | nil,
          deprecated: [Proto.Timeline.Specialist.t()],
          specialists: [Proto.Generics.Specialist.t()]
        }

  defstruct [:timeline, :deprecated, :specialists]

  field :timeline, 1, type: Proto.Timeline.Timeline
  field :deprecated, 2, repeated: true, type: Proto.Timeline.Specialist
  field :specialists, 3, repeated: true, type: Proto.Generics.Specialist
end

defmodule Proto.Timeline.NewTimelineItem do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          record_id: non_neg_integer,
          timeline_item: Proto.Timeline.TimelineItem.t() | nil,
          specialist: Proto.Timeline.Specialist.t() | nil,
          specialists: [Proto.Generics.Specialist.t()]
        }

  defstruct [:record_id, :timeline_item, :specialist, :specialists]

  field :record_id, 1, type: :uint64
  field :timeline_item, 2, type: Proto.Timeline.TimelineItem
  field :specialist, 3, type: Proto.Timeline.Specialist
  field :specialists, 4, repeated: true, type: Proto.Generics.Specialist
end

defmodule Proto.Timeline.Timeline do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          timeline_items: [Proto.Timeline.TimelineItem.t()]
        }

  defstruct [:timeline_items]

  field :timeline_items, 1, repeated: true, type: Proto.Timeline.TimelineItem
end

defmodule Proto.Timeline.TimelineItem.Call do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          specialist_id: non_neg_integer,
          category_id: non_neg_integer
        }

  defstruct [:specialist_id, :category_id]

  field :specialist_id, 1, type: :uint64
  field :category_id, 2, type: :uint64
end

defmodule Proto.Timeline.TimelineItem.DispatchRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          requester_id: non_neg_integer,
          patient_location: Proto.Dispatches.PatientLocation.t() | nil
        }

  defstruct [:requester_id, :patient_location]

  field :requester_id, 1, type: :uint64
  field :patient_location, 2, type: Proto.Dispatches.PatientLocation
end

defmodule Proto.Timeline.TimelineItem.Vitals do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          nurse_id: non_neg_integer,
          vitals_entry: Proto.Vitals.VitalsEntry.t() | nil
        }

  defstruct [:nurse_id, :vitals_entry]

  field :nurse_id, 1, type: :uint64
  field :vitals_entry, 2, type: Proto.Vitals.VitalsEntry
end

defmodule Proto.Timeline.TimelineItem.OrderedTests do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          specialist_id: non_neg_integer,
          items: [Proto.EMR.OrderedTestsItem.t()]
        }

  defstruct [:specialist_id, :items]

  field :specialist_id, 1, type: :uint64
  field :items, 2, repeated: true, type: Proto.EMR.OrderedTestsItem
end

defmodule Proto.Timeline.TimelineItem.Medications do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          specialist_id: non_neg_integer,
          items: [Proto.EMR.MedicationsItem.t()]
        }

  defstruct [:specialist_id, :items]

  field :specialist_id, 1, type: :uint64
  field :items, 2, repeated: true, type: Proto.EMR.MedicationsItem
end

defmodule Proto.Timeline.TimelineItem.DoctorInvitation do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          specialist_id: non_neg_integer,
          medical_category_id: non_neg_integer
        }

  defstruct [:specialist_id, :medical_category_id]

  field :specialist_id, 1, type: :uint64
  field :medical_category_id, 2, type: :uint64
end

defmodule Proto.Timeline.TimelineItem.ProvidedHPI do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          hpi: Proto.EMR.HPI.t() | nil,
          specialist_id: non_neg_integer
        }

  defstruct [:hpi, :specialist_id]

  field :hpi, 1, type: Proto.EMR.HPI
  field :specialist_id, 2, type: :uint64
end

defmodule Proto.Timeline.TimelineItem.CallRecording do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          video_url: String.t(),
          thumbnail_url: String.t(),
          session_id: String.t()
        }

  defstruct [:video_url, :thumbnail_url, :session_id]

  field :video_url, 1, type: :string
  field :thumbnail_url, 2, type: :string
  field :session_id, 3, type: :string
end

defmodule Proto.Timeline.TimelineItem do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          item: {atom, any},
          id: String.t(),
          timestamp: non_neg_integer,
          comments_counter: non_neg_integer
        }

  defstruct [:item, :id, :timestamp, :comments_counter]

  oneof :item, 0
  field :id, 8, type: :string
  field :timestamp, 1, type: :uint64
  field :comments_counter, 9, type: :uint32
  field :call, 2, type: Proto.Timeline.TimelineItem.Call, oneof: 0
  field :dispatch_request, 3, type: Proto.Timeline.TimelineItem.DispatchRequest, oneof: 0
  field :vitals, 4, type: Proto.Timeline.TimelineItem.Vitals, oneof: 0
  field :doctor_invitation, 5, type: Proto.Timeline.TimelineItem.DoctorInvitation, oneof: 0
  field :provided_hpi, 6, type: Proto.Timeline.TimelineItem.ProvidedHPI, oneof: 0
  field :call_recording, 7, type: Proto.Timeline.TimelineItem.CallRecording, oneof: 0
  field :vitals_v2, 10, type: Proto.EMR.Vitals, oneof: 0
  field :ordered_tests, 11, type: Proto.Timeline.TimelineItem.OrderedTests, oneof: 0
  field :medications, 12, type: Proto.Timeline.TimelineItem.Medications, oneof: 0
end

defmodule Proto.Timeline.Specialist do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          id: non_neg_integer,
          first_name: String.t(),
          last_name: String.t(),
          avatar_url: String.t(),
          type: Proto.Timeline.Specialist.Type.t(),
          medical_categories: [String.t()]
        }

  defstruct [:id, :first_name, :last_name, :avatar_url, :type, :medical_categories]

  field :id, 1, type: :uint64
  field :first_name, 2, type: :string
  field :last_name, 3, type: :string
  field :avatar_url, 4, type: :string
  field :type, 5, type: Proto.Timeline.Specialist.Type, enum: true
  field :medical_categories, 6, repeated: true, type: :string
end
